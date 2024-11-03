//
//  ListadoServiciosView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 26/8/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import SDWebImageSwiftUI

struct ListadoSolicitudesView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    
    @State private var openLoadingSpinner:Bool = true
    @State private var showToastBool:Bool = false
    @State var itemsListado: [ModeloListadoSolicitudes] = []
    @State private var pantallaCargada: Bool = false
    @State private var boolNoHayDatos: Bool = false
    @State private var popPreguntarOcultar: Bool = false
    @State private var idFilaTipoSolicitud: Int = 0
    @State private var idFilaSolicitud: Int = 0
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModelOcultar = ListadoSolicitudesOcultarViewModel()
    @StateObject var viewModel = ListadoSolicitudesViewModel()
    
    let disposeBag = DisposeBag()
   
    var body: some View {
        VStack {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                
                    VStack(spacing: 0) {
                        
                        if pantallaCargada {
                            List {
                                ForEach(itemsListado.indices, id: \.self) { index in
                                    let _servicio = itemsListado[index]
                                    
                                    
                                    // BASICO
                                    if _servicio.tipo == 1 {
                                        CardViewDenunciaBasica(nombretipo: _servicio.nombretipo, estado: _servicio.estado, nota: _servicio.nota, fecha: _servicio.fecha, onTap: {
                                            abrirPopOcultar(_idfilaSolicitud: _servicio.id, _idfilaTipoSolicitud: _servicio.tipo)
                                        })
                                    }
                                    
                                    // SOLICITUD TALA ARBOL
                                    else if _servicio.tipo == 2 {
                                        CardViewSolicitudTalaArbol(nombretipo: _servicio.nombretipo, estado: _servicio.estado, nota: _servicio.nota, fecha: _servicio.fecha, nombre: _servicio.nombre, telefono: _servicio.telefono, direccion: _servicio.direccion, escritura: _servicio.escritura, imagen: _servicio.imagen, onTap: {
                                            abrirPopOcultar(_idfilaSolicitud: _servicio.id, _idfilaTipoSolicitud: _servicio.tipo)
                                        })
                                    }
                                    
                                    // DENUNCIA TALA DE ARBOL
                                    else if _servicio.tipo == 3 {
                                        CardViewDenunciaTalaArbol(nombretipo: _servicio.nombretipo, estado: _servicio.estado, nota: _servicio.nota, fecha: _servicio.fecha, imagen: _servicio.imagen, onTap: {
                                            abrirPopOcultar(_idfilaSolicitud: _servicio.id, _idfilaTipoSolicitud: _servicio.tipo)
                                        })
                                    }
                                    
                                    // CATASTRO
                                    else if _servicio.tipo == 4 {
                                        CardViewSolicitudCatastro(nombretipo: _servicio.nombretipo, estado: _servicio.estado, fecha: _servicio.fecha, nombre: _servicio.nombre, dui: _servicio.dui, onTap: {
                                            abrirPopOcultar(_idfilaSolicitud: _servicio.id, _idfilaTipoSolicitud: _servicio.tipo)
                                        })
                                    }
                                    
                                }
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(PlainListStyle())
                            .refreshable {
                                // RECARGAR AL HACER SCROLL
                                serverListado()
                            }
                        }else{
                            // mostrar que no hay datos
                            if boolNoHayDatos {
                                CardViewNoHayDatos()
                            }
                        }
                    }
                    .onAppear{
                        serverListado()
                    }
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity) // Transición de opacidad
                        .zIndex(10)
                }
      
                
                // preguntar si quiere ocultar solicitud
                if popPreguntarOcultar {
                    PopImg2BtnView(isActive: $popPreguntarOcultar, imagen: .constant("infocolor"), descripcion: .constant("¿Ocultar Solicitud?"), txtCancelar: .constant("No"), txtAceptar: .constant("Si"), cancelAction: {
                        popPreguntarOcultar = false
                    }, acceptAction: {
                        serverOcultarSolicitud()
                    }).zIndex(1)
                }
            }
        }
        .navigationTitle("Solicitudes")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                        
                        Text("Atras")
                            .foregroundColor(.black)
                    }
                }           
            }
        }
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onReceive(viewModelOcultar.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
      
    
    func abrirPopOcultar(_idfilaSolicitud: Int, _idfilaTipoSolicitud: Int){
        idFilaSolicitud = _idfilaSolicitud
        idFilaTipoSolicitud = _idfilaTipoSolicitud
        popPreguntarOcultar = true
    }
    
    func serverListado(){
        itemsListado.removeAll()
        openLoadingSpinner = true
        pantallaCargada = false
        
        viewModel.misSolicitudesRX(idToken: idToken, idcliente: 2) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
              
                    let _haydatos = json["haydatos"].int ?? 0
                     
                     if _haydatos == 1 {
                         json["listado"].array?.forEach({ (dataArray) in
                             
                             let _id = dataArray["id"].int ?? 0
                             let _tipo = dataArray["tipo"].int ?? 0
                             let _nombretipo = dataArray["nombretipo"].string ?? ""
                             let _estado = dataArray["estado"].string ?? ""
                             let _nota = dataArray["nota"].string ?? ""
                             let _fecha = dataArray["fecha"].string ?? ""
                             let _nombre = dataArray["nombre"].string ?? ""
                             let _telefono = dataArray["telefono"].string ?? ""
                             let _direccion = dataArray["direccion"].string ?? ""
                             let _escritura = dataArray["escritura"].int ?? 0
                             let _dui = dataArray["dui"].string ?? ""
                             let _imagen = dataArray["imagen"].string ?? ""
                             
                             let _array = ModeloListadoSolicitudes(id: _id, tipo: _tipo, nombretipo: _nombretipo, estado: _estado, nota: _nota, fecha: _fecha, nombre: _nombre, telefono: _telefono, direccion: _direccion, escritura: _escritura, dui: _dui, imagen: _imagen)
                                                                 
                             itemsListado.append(_array)
                         })
                       
                          pantallaCargada = true
                     }else{
                         pantallaCargada = false
                         boolNoHayDatos = true
                     }
                                        
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    
    func serverOcultarSolicitud(){
        openLoadingSpinner = true
        viewModelOcultar.ocultarSolicitudesRX(idToken: idToken, id: idFilaSolicitud, tipo: idFilaTipoSolicitud) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
              
                    idFilaSolicitud = 0
                    idFilaTipoSolicitud = 0
                    serverListado()
                                        
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


// CARDVIEW PARA DENUNCIAS BASICAS
struct CardViewDenunciaBasica: View {
    var nombretipo: String
    var estado: String
    var nota: String
    var fecha: String
    
    var onTap: () -> Void
    var body: some View {
        VStack {
            
            BloqueFilaSolicitud(nombretipo: "Tipo: ", texto: nombretipo)
            BloqueFilaSolicitud(nombretipo: "Fecha: ", texto: fecha)
            BloqueFilaSolicitud(nombretipo: "Estado: ", texto: estado)
            if !nota.isEmpty {
                BloqueFilaSolicitud(nombretipo: "Nota: ", texto: nota)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
       
        .onTapGesture {
            onTap()
        }
    }
}


// CARDVIEW SOLICITUD TALA ARBOL
struct CardViewSolicitudTalaArbol: View {
    var nombretipo: String
    var estado: String
    var nota: String
    var fecha: String
    var nombre: String
    var telefono: String
    var direccion: String
    var escritura: Int
    var imagen: String
    
    var onTap: () -> Void
    var body: some View {
        VStack {
       
            BloqueFilaSolicitud(nombretipo: "Tipo: ", texto: nombretipo)
            BloqueFilaSolicitud(nombretipo: "Fecha: ", texto: fecha)
            BloqueFilaSolicitud(nombretipo: "Estado: ", texto: estado)
            BloqueFilaSolicitud(nombretipo: "Nombre: ", texto: nombre)
            BloqueFilaSolicitud(nombretipo: "Teléfono: ", texto: telefono)
            BloqueFilaSolicitud(nombretipo: "Dirección: ", texto: direccion)
            
            if (escritura == 1) {
                BloqueFilaSolicitud(nombretipo: "Escritura: ", texto: "Si")
            }else {
                BloqueFilaSolicitud(nombretipo: "Escritura: ", texto: "No")
            }
            
            if !nota.isEmpty {
                BloqueFilaSolicitud(nombretipo: "Nota: ", texto: nota)
            }
                     
            WebImage(url: URL(string: baseUrlImagen + imagen))
                           .resizable()
                           .indicator(.activity)
                           .scaledToFit()
                           .frame(height: 200)
                           .padding(.top, 10)
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
       
        .onTapGesture {
            onTap()
        }
    }
}


// CARDVIEW DENUNCIA TALA DE ARBOL
struct CardViewDenunciaTalaArbol: View {
    var nombretipo: String
    var estado: String
    var nota: String
    var fecha: String
    var imagen: String
    
    var onTap: () -> Void
    var body: some View {
        VStack {
            
            BloqueFilaSolicitud(nombretipo: "Tipo: ", texto: nombretipo)
            BloqueFilaSolicitud(nombretipo: "Fecha: ", texto: fecha)
            BloqueFilaSolicitud(nombretipo: "Estado: ", texto: estado)
                    
            WebImage(url: URL(string: baseUrlImagen + imagen))
                           .resizable()
                           .indicator(.activity)
                           .scaledToFit()
                           .frame(height: 200)
                           .padding(.top, 10)
            
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
       
        .onTapGesture {
            onTap()
        }
    }
}


// CRDVIEW SOLICITUD CATASTRO
struct CardViewSolicitudCatastro: View {
    var nombretipo: String
    var estado: String
    var fecha: String
    var nombre: String
    var dui: String
        
    var onTap: () -> Void
    var body: some View {
        VStack {
                     
            BloqueFilaSolicitud(nombretipo: "Tipo: ", texto: nombretipo)
            BloqueFilaSolicitud(nombretipo: "Fecha: ", texto: fecha)
            BloqueFilaSolicitud(nombretipo: "Estado: ", texto: estado)
            BloqueFilaSolicitud(nombretipo: "Nombre: ", texto: nombre)
            BloqueFilaSolicitud(nombretipo: "DUI: ", texto: dui)
            
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
       
        .onTapGesture {
            onTap()
        }
    }
}

struct BloqueFilaSolicitud: View {
    var nombretipo: String
    var texto: String
 
    var body: some View {
        HStack {
            Text(nombretipo)
                .font(.custom("LiberationSans-Bold", size: 17))
            Text(texto)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Alinear a la izquierda
        .padding(.horizontal, 10)
        .padding(.top, 8)
    }
}

struct CardViewNoHayDatos: View {
   
    var body: some View {
        VStack {
            Image("noinfo")
               .resizable()
               .scaledToFit()
               .frame(height: 80)
            
            Text("No hay Solicitudes")
                .font(.custom("LiberationSans-Bold", size: 17))
                .padding(.top, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
     
    }
}

