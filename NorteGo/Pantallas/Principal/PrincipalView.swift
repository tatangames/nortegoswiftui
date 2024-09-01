//
//  PrincipalView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 16/8/24.
//

import SwiftUI
import SwiftUI_Shimmer
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import SDWebImageSwiftUI

struct PrincipalView: View {
    
    @State var width = UIScreen.main.bounds.width - 90
    @State var x = -UIScreen.main.bounds.width + 90
    @State private var pantallaCargada:Bool = false
    @State private var openLoadingSpinner:Bool = true
    @State private var showToastBool:Bool = false
    @State private var popNumeroBloqueado: Bool = false
    @State private var popCerrarSesion: Bool = false
    @State var itemsSlider: [ModeloSlider] = []
    @State var itemsTipoServicioArray: [ModeloTipoServicioArray] = []
    @State var itemsTipoServicio: [ModeloTipoServicio] = []
    @State private var datosCargados:Bool = false
    @State var popNuevoServicio:Bool = false
    @State private var popNuevaActualizacion: Bool = false
    
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    let disposeBag = DisposeBag()
    let appBuild: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    @State var popVista:Bool = false
    @State var vistaSeleccionada: AnyView? = nil
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                
                if(pantallaCargada){
                    VStack(spacing: 0) {
                        
                        
                        ToolbarPrincipalView(x: $x)
                        ContenidoServicios(itemsSlider: itemsSlider,
                                           itemServicioArray: itemsTipoServicioArray,
                                           popNuevoServicioBindind: $popNuevoServicio,
                                           vistaSeleccionada: $vistaSeleccionada)
                        
                    }
                    SideMenuView(x: $x, popCerrarSesion: $popCerrarSesion)
                        .shadow(color: Color.black.opacity(x != 0 ? 0.1 : 0), radius: 5,
                                x: 5, y: 0)
                        .offset(x: x)
                        .background(Color.black.opacity(x == 0 ? 0.5 : 0).ignoresSafeArea(.all, edges:
                                .vertical).onTapGesture {
                                    withAnimation{
                                        x = -width
                                    }
                                })
                    
                }else{
                    ContenedorShimmer().shimmering()
                }
                
               
                
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity) // Transición de opacidad
                        .zIndex(10)
                }
                
                // Pop-up numero bloqueado
                if popNumeroBloqueado {
                    PopImg1BtnView(isActive: $popNumeroBloqueado, imagen: .constant("infocolor"), bLlevaTitulo: .constant(true), titulo: .constant("Bloqueado"), descripcion: .constant("Número de teléfono bloqueado, contactar a la Administración"), txtAceptar: .constant("Aceptar"), acceptAction: {
                        
                        salirSplashView()
                    })
                    .zIndex(1)
                }
                
                // Pop-up numero bloqueado
                if popNuevaActualizacion {
                    PopImg2BtnView(isActive: $popNuevaActualizacion, imagen: .constant("infocolor"), descripcion: .constant("Hay una nueva versión disponible. ¿Desea actualizar ahora?"), txtCancelar: .constant("No"), txtAceptar: .constant("Actualizar"), cancelAction: {}, acceptAction: {
                        if let url = URL(string: apiURLAppleStore) {
                            UIApplication.shared.open(url)
                        }
                    }).zIndex(1)
                }
                
                if popNuevoServicio {
                    PopImg2BtnView(isActive: $popNuevoServicio, imagen: .constant("infocolor"), descripcion: .constant("Por favor, actualiza la aplicación para acceder a este servicio"), txtCancelar: .constant("No"), txtAceptar: .constant("Actualizar"), cancelAction: {popNuevoServicio = false}, acceptAction: {
                        if let url = URL(string: apiURLAppleStore) {
                            UIApplication.shared.open(url)
                        }
                    }).zIndex(1)
                }
                
                if popCerrarSesion {
                    PopImg2BtnView(isActive: $popCerrarSesion, imagen: .constant("infocolor"), descripcion: .constant("Cerrar Sesión"), txtCancelar: .constant("No"), txtAceptar: .constant("Si"), cancelAction: {popCerrarSesion = false}, acceptAction: {
                        
                        salirSplashView()
                            
                    }).zIndex(1)
                }
                
            }
            
            .navigationDestination(isPresented: Binding(
                get: { vistaSeleccionada != nil },
                set: { _ in vistaSeleccionada = nil }
            )) {
                vistaSeleccionada
            }
            
            .gesture(DragGesture().onChanged({ (value) in
                
                /*withAnimation{
                 if value.startLocation.x < UIScreen.main.bounds.width / 2 {
                 // Permitir solo el arrastre de izquierda a derecha
                 if value.translation.width > 0 {
                 // Desactivar el arrastre en exceso
                 if x < 0 {
                 x = -width + value.translation.width
                 }
                 }
                 }
                 }*/
            }).onEnded({ (value) in
                
                /*withAnimation{
                 if -x < width / 2 {
                 x = 0
                 } else {
                 x = -width
                 }
                 }*/
            }))
            /* .onAppear{
             serverPrincipal()
             }*/
        }
        
        .onAppear {
            if !datosCargados {
                serverPrincipal()
                datosCargados = true
            }
        }
        .toast(isPresenting: $showToastBool, duration: 3, tapToDismiss: false) {
            customToast
        }
    }
    
    
    //*** FUNCIONES ****
    
    func salirSplashView(){
        
        idToken = ""
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: SplashScreenView())
                window.makeKeyAndVisible()
            }
        }
    }
  
    func serverPrincipal(){
        
        openLoadingSpinner = true
        
        let encodeURL = apiPrincipal
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)"
        ]
        
        let parameters: [String: Any] = [
            "iduser": 0
        ]
        
        Observable<Void>.create { observer in
            let request = AF.request(encodeURL, method: .post, parameters: parameters, headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        
                        let json = JSON(data)
                        openLoadingSpinner = false
                        
                        if let successValue = json["success"].int {
                            
                            if(successValue == 1){
                                // El usuario esta bloqueado
                               
                                popNumeroBloqueado = true
                            }
                            else if (successValue == 2){
                                let _codeiphone = json["codeiphone"].int ?? 0
                                
                                // verificar si hay actualizacion
                                if !appBuild.isEmpty {
                                    if _codeiphone != Int(appBuild) {
                                        popNuevaActualizacion = true
                                    }
                                }
                                                                
                                json["slider"].array?.forEach({ (dataArray) in
                                    
                                    let _id = dataArray["id"].int ?? 0
                                    let _imagen = dataArray["imagen"].string ?? ""
                                    
                                    let _array = ModeloSlider(id: _id, imagen: _imagen)
                                    
                                    itemsSlider.append(_array)
                                })
                                
                                
                                json["tiposervicio"].array?.forEach({ (dataArray) in
                                    
                                    let _id = dataArray["id"].int ?? 0
                                    let _nombre = dataArray["nombre"].string ?? ""
                                    
                                    
                                    dataArray["lista"].array?.forEach { (listaItem) in
                                        let _id2 = listaItem["id"].int ?? 0
                                        let _idcateservicio = listaItem["id_cateservicio"].int ?? 0
                                        let _tiposervicio = listaItem["tiposervicio"].int ?? 0
                                        let _nombre = listaItem["nombre"].string ?? ""
                                        let _imagen = listaItem["imagen"].string ?? ""
                                        
                                        let _arrayTipoServicio = ModeloTipoServicio(id: _id2, id_cateservicio: _idcateservicio, tiposervicio: _tiposervicio, nombre: _nombre, imagen: _imagen)
                                        
                                        itemsTipoServicio.append(_arrayTipoServicio)
                                    }
                                    
                                    let _arrayTipoServicioArray = ModeloTipoServicioArray(id: _id, nombre: _nombre, lista: itemsTipoServicio)
                                    
                                    itemsTipoServicioArray.append(_arrayTipoServicioArray)
                                    itemsTipoServicio.removeAll()
                                })
                                
                                pantallaCargada = true
                            }
                            else{
                                showCustomToast(with: "Error")
                            }
                            
                        }else{
                            showCustomToast(with: "Error")
                        }
                        
                    case .failure(_):
                        openLoadingSpinner = false
                        showCustomToast(with: "Error")
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
        .retry() // Retry indefinitely
        .subscribe(onNext: {
            // Hacer algo cuando la solicitud tenga éxito
            
        }, onError: { error in
            // Manejar el error de la solicitud
            openLoadingSpinner = false
            showCustomToast(with: "Error")
        })
        .disposed(by: disposeBag)
    }
    
    
    // Función para configurar y mostrar el toast
    func showCustomToast(with mensaje: String) {
        customToast = AlertToast(
            displayMode: .banner(.pop),
            type: .regular,
            title: mensaje,
            subTitle: nil,
            style: .style(
                backgroundColor: Color("ColorAzulToast"),
                titleColor: Color.white,
                subTitleColor: Color.blue,
                titleFont: .headline,
                subTitleFont: nil
            )
        )
        showToastBool = true
    }
}



// CONTENIDO QUE CARGA AL RESPONDER PETICION API
struct ContenidoServicios:View {
    
    @State var itemsSlider: [ModeloSlider] = []
    @State var itemServicioArray: [ModeloTipoServicioArray] = []
    @Binding var popNuevoServicioBindind: Bool
    @Binding var vistaSeleccionada: AnyView?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        List {
            
            ImageSliderView(images: itemsSlider)
                .listRowInsets(EdgeInsets())
            
            ForEach(itemServicioArray.indices, id: \.self) { index in
                let servicioArray = itemServicioArray[index]
                
                Text(servicioArray.nombre)
                    .font(.custom("LiberationSans-Bold", size: 18))
                    .foregroundColor(Color.gray)
                    .background(Color.white)
                    .padding(.top) // Opcional: Ajusta el padding según sea necesario
                                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(servicioArray.lista, id: \.id) { servicio in
                        
                        CardView(image: servicio.imagen, title: servicio.nombre) {
                            redireccionamiento(_tiposervicio: servicio.tiposervicio, _id: servicio.id, _titulo: servicio.nombre)
                        }
                    }
                }
                .padding(.vertical)
                .listRowInsets(EdgeInsets())
                
                // Agregar el Divider solo si no es la última sección
                if index != itemServicioArray.indices.last {
                    Divider()
                        .frame(height: 0.14)
                        .background(Color.gray)
                }
            }
            .listRowSeparator(.hidden)
            
            
        }
        .listStyle(PlainListStyle())
        
    }
    
    // ** FUNCIONES **
    
    func redireccionamiento(_tiposervicio: Int, _id: Int, _titulo: String){
        
        // ID SERVICIOS DISPONIBLES, SINO MOSTRAR QUE ESTE SERVICIO NUEVO NECESITA ACTUALIZACION
        let supportedTypes: [Int] = [1,2,3,4]
        
        if supportedTypes.contains(_tiposervicio) {
            if _tiposervicio == 1 {
                // SERVICIO BASICO
                // .environmentObject(locationManager)
                vistaSeleccionada = AnyView(DenunciaBasicaView(idServicio: _id, tituloVista: _titulo))
            }
            else if _tiposervicio == 2 {
                // DENUNCIA DE TALA ARBOL
                vistaSeleccionada = AnyView(SolicitudTalaArbolView(idServicio: _id, tituloVista: _titulo))
            }
            else if _tiposervicio == 3 {
                // REDIRECCIONAR A DENUNCIA
                openWhatsApp(with: "50375825072")
            }
            else if _tiposervicio == 4 {
                // CATASTRO
                vistaSeleccionada = AnyView(SolvenciaCatastroView(tituloVista: _titulo))
            }
        }else{
            // nuevo servicio, se necesita actualizacion
            popNuevoServicioBindind = true
        }
    }
    
    
    func openWhatsApp(with phoneNumber: String) {
            let urlWhatsApp = "https://wa.me/\(phoneNumber)"
            
            if let urlString = urlWhatsApp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("No se puede abrir WhatsApp")
                }
            }
        }
    
}




// VISTA PARA IMAGEN SLIDER
struct ImageSliderView: View {
    let images: [ModeloSlider]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    let base = baseUrlImagen
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(images.indices, id: \.self) { index in
                          
                WebImage(url: URL(string: base + images[index].imagen))
                    .resizable()
                    .indicator(.activity)
                    .scaledToFill()
                    .tag(index)
                    .frame(maxWidth: .infinity, maxHeight: 250)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 250) // Altura del slider
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % images.count
            }
        }
    }
}



// VISTA SHIMMER PARA LOADING AL INICIAR
struct ContenedorShimmer: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        VStack(spacing: 20) {
            // Fondo de color que ocupa todo el ancho y tiene 280 de altura
            Rectangle()
                .fill(Color.gray) // Cambia el color según tu necesidad
                .frame(height: 280)
            
            // Grid con 2 columnas y 3 filas
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<6) { _ in
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 160)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top,40)
    }
}




/*
#Preview {
    return PrincipalView()
}*/


