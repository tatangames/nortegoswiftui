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
    @State private var pantallaCargada = false
    @State private var openLoadingSpinner = true
    @State private var showToastBool = false
    @State private var popNumeroBloqueado: Bool = false
    @State var itemsSlider: [ModeloSlider] = []
    @State var itemsTipoServicioArray: [ModeloTipoServicioArray] = []
    @State var itemsTipoServicio: [ModeloTipoServicio] = []
    @State private var boolSalir = false
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    let disposeBag = DisposeBag()
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
      
    var body: some View {
        
        NavigationView {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                
                if(pantallaCargada){
                    VStack(spacing: 0) {
                        
                        if !boolSalir {
                            ToolbarPrincipalView(x: $x)
                            ContenidoServicios(itemsSlider: itemsSlider, itemServicioArray: itemsTipoServicioArray)
                        }
                    }
                    SideMenuView(x: $x)
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
                       
                        idToken = ""
                        salirAlInicio()
                    })
                        .zIndex(1)
                }
                
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
            .onAppear{
                serverPrincipal()
            }
        }
        .fullScreenCover(isPresented: $boolSalir) {
            return SplashScreenView()
        }
    }
    
    func salirAlInicio(){
        boolSalir = true
    }
    
    
    //*** FUNCIONES ****
    
    
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
                                let _codeiphone = json["success"].int ?? 0
                                                                
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
                            print("Se tocó el servicio: \(servicio.nombre)")
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
}

// ESTRUCTURA DE CADA OPCION CARDVIEW
struct CardView: View {
    var image: String
    var title: String
    var onTap: () -> Void
    var body: some View {
        VStack {
            
            WebImage(url: URL(string: baseUrlImagen + image))
                .resizable()
                .indicator(.activity)
                .scaledToFit()
                .frame(height: 100)
                .padding(.top, 10)
            
            Text(title)
                .font(.headline)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            
            
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 10)
        .onTapGesture {
            onTap()
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



