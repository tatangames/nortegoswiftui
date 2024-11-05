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
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    @AppStorage(DatosGuardadosKeys.idAppVersion) private var idAppVersionLocal: String = ""
    
    @State private var width = UIScreen.main.bounds.width - 90
    @State private var x = -UIScreen.main.bounds.width + 90
    @State private var pantallaCargada:Bool = false
    @State private var openLoadingSpinner:Bool = true
    @State private var showToastBool:Bool = false
    @State private var popNumeroBloqueado: Bool = false
    @State private var popCerrarSesion: Bool = false
    @State private var datosCargados:Bool = false
    @State private var popNuevoServicio:Bool = false
    @State private var popNuevaActualizacion: Bool = false
    @State private var popVista:Bool = false
    @State private var vistaSeleccionada: AnyView? = nil
    @StateObject var viewModel = PrincipalViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    @State private var onesignal: String = ""
    @State private var boolSeguroVersionBackend:Bool = true
    @State private var urlAppStore:String = ""
    
    @State var itemsSlider: [ModeloSlider] = []
    @State var itemsTipoServicioArray: [ModeloTipoServicioArray] = []
    @State var itemsTipoServicio: [ModeloTipoServicio] = []
    let disposeBag = DisposeBag()
    
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
                
                // pop nueva actualizacion
                if popNuevaActualizacion {
                    PopImg2BtnView(isActive: $popNuevaActualizacion, imagen: .constant("infocolor"), descripcion: .constant("Hay una nueva versión disponible. ¿Desea actualizar ahora?"), txtCancelar: .constant("No"), txtAceptar: .constant("Actualizar"), cancelAction: {}, acceptAction: {
                        if let url = URL(string: urlAppStore) {
                            UIApplication.shared.open(url)
                        }
                    }).zIndex(1)
                }
                
                // cuando haya nueva version
                if popNuevoServicio {
                    PopImg2BtnView(isActive: $popNuevoServicio, imagen: .constant("infocolor"), descripcion: .constant("Por favor, actualiza la aplicación para acceder a este servicio"), txtCancelar: .constant("No"), txtAceptar: .constant("Actualizar"), cancelAction: {popNuevoServicio = false}, acceptAction: {
                        if let url = URL(string: urlAppStore) {
                            UIApplication.shared.open(url)
                        }
                    }).zIndex(1)
                }
                
                // cierre de sesion
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
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
        
    }
    
    
    //*** FUNCIONES ****
    
    func salirSplashView(){
        idToken = ""
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: SplashScreenView().preferredColorScheme(.light) )
                window.makeKeyAndVisible()
            }
        }
    }
    
    func serverPrincipal(){
        
        openLoadingSpinner = true
        
        viewModel.principalRX(idToken: idToken, onesignal: onesignal) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    // numero bloqueado
                    popNumeroBloqueado = true
                case 2:
                    
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
                            let _descripcion = listaItem["descripcion"].string ?? ""
                            
                            let _arrayTipoServicio = ModeloTipoServicio(id: _id2, id_cateservicio: _idcateservicio, tiposervicio: _tiposervicio, nombre: _nombre, imagen: _imagen, descripcion: _descripcion)
                            
                            itemsTipoServicio.append(_arrayTipoServicio)
                        }
                        
                        let _arrayTipoServicioArray = ModeloTipoServicioArray(id: _id, nombre: _nombre, lista: itemsTipoServicio)
                        
                        itemsTipoServicioArray.append(_arrayTipoServicioArray)
                        itemsTipoServicio.removeAll()
                    })
                    
                    let _versionIOS = json["versionios"].string ?? ""
                    let _modalios = json["modalios"].int ?? 0
                    let _urlApp = json["urlapplestore"].string ?? ""
                    
                    urlAppStore = _urlApp
                   
                    
                    // esto se hace una sola vez cuando la app es nueva
                    if(idAppVersionLocal.isEmpty){
                        boolSeguroVersionBackend = false
                        idAppVersionLocal = _versionIOS
                    }
                    
                    // verificar si hay actualizacion
                    if _modalios == 1{
                        if ((idAppVersionLocal != _versionIOS) && boolSeguroVersionBackend) {
                            popNuevaActualizacion = true
                        }
                    }
                    
                    // SIEMPRE GUARDAR LA VERSION BACKEND
                    idAppVersionLocal = _versionIOS
                                        
                    pantallaCargada = true
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    
    func mensajeError(){
        toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
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
                            redireccionamiento(_tiposervicio: servicio.tiposervicio, _id: servicio.id, _titulo: servicio.nombre,
                                               _descripcion: servicio.descripcion)
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
    
    func redireccionamiento(_tiposervicio: Int, _id: Int, _titulo: String, _descripcion: String){
        
        // ID SERVICIOS DISPONIBLES, SINO MOSTRAR QUE ESTE SERVICIO NUEVO NECESITA ACTUALIZACION
        let supportedTypes: [Int] = [1,2,3,4]
        
        if supportedTypes.contains(_tiposervicio) {
            if _tiposervicio == 1 {
                // SERVICIO BASICO
                // .environmentObject(locationManager)
                vistaSeleccionada = AnyView(DenunciaBasicaView(idServicio: _id, tituloVista: _titulo, descripcion: _descripcion))
            }
            else if _tiposervicio == 2 {
                // DENUNCIA DE TALA ARBOL
                vistaSeleccionada = AnyView(SolicitudTalaArbolView(idServicio: _id, tituloVista: _titulo))
            }
            else if _tiposervicio == 3 {
                // REDIRECCIONAR A DENUNCIA
                openWhatsApp(with: "50369886392")
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
                    .scaledToFit()
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
