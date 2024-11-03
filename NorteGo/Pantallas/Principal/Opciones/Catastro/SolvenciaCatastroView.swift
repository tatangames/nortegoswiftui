//
//  SolvenciaCatastroView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 28/8/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast

struct SolvenciaCatastroView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    
    @State var tituloVista:String = ""
    @State private var selectedOption:Int = 0
    @State private var showToastBool:Bool = false
    @State private var nombre:String = ""
    @State private var dui:String = ""
    @State private var openLoadingSpinner:Bool = false
    @State private var popDatosEnviados:Bool = false
    @StateObject var viewModel = SolvenciaCatastroViewModel()
    //GPS
    @State private var latitudFinal:String = ""
    @State private var longitudFinal:String = ""
    @StateObject private var locationManager = LocationManager()
    @StateObject private var toastViewModel = ToastViewModel()
    
    let disposeBag = DisposeBag()
    
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    VStack(alignment: .leading) { // Alinear a la izquierda
                        RadioButton(id: 1, label: "Solvencia de Inmueble", isSelected: $selectedOption)
                        RadioButton(id: 2, label: "Solvencia de Empresa", isSelected: $selectedOption)
                            .padding(.top, 15)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 35)
                    
                    // Alinea el texto a la izquierda
                    HStack {
                        Text("Nombre Completo")
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 45)
                    
                    VStack {
                        TextField("Nombre", text: $nombre)
                            .onChange(of: nombre) { newValue in
                                if newValue.count > 100 {
                                    nombre = String(newValue.prefix(100))
                                }
                            }
                            .padding(.bottom, 0)
                        // Línea subrayada
                        Rectangle()
                            .frame(height: 1) // Altura de la línea
                            .foregroundColor(.gray) // Color de la línea
                    }
                                        
                    // Alinea el texto a la izquierda
                    HStack {
                        Text("DUI")
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    VStack {
                        TextField("DUI", text: $dui)
                            .onChange(of: dui) { newValue in
                                if newValue.count > 15 {
                                    dui = String(newValue.prefix(15))
                                }
                            }
                            .padding(.bottom, 0) // Añade espacio entre el texto y la línea
                        
                        // Línea subrayada
                        Rectangle()
                            .frame(height: 1) // Altura de la línea
                            .foregroundColor(.gray) // Color de la línea
                    }
                                        
                    Button(action: { // btn enviar datos
                        serverEnviarDatos()
                    }) {
                        Text("ENVIAR")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.ColorAzulGob)
                            .cornerRadius(8)
                    }
                    .padding(.top, 50)
                    .opacity(1.0)
                    .buttonStyle(NoOpacityChangeButtonStyle())
                    Spacer()
                }               
                .padding()                
                .navigationTitle(tituloVista)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Regresa a la pantalla anterior
                        }) {
                            HStack {
                                Image(systemName: "arrow.left") // Ícono personalizado
                                    .foregroundColor(.black)
                                Text("Atras") // Texto personalizado
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .onReceive(locationManager.$location) { newLocation in
                    if let location = newLocation {
                        latitudFinal = String(location.latitude)
                        longitudFinal = String(location.longitude)
                    }
                }
                .onAppear{
                    locationManager.getLocation()
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity) // Transición de opacidad
                    .zIndex(10)
            }
            
            if popDatosEnviados {
                PopImg1BtnView(isActive: $popDatosEnviados, imagen: .constant("infocolor"), bLlevaTitulo: .constant(true), titulo: .constant("Enviado"), descripcion: .constant("Puede verificar la solicitud en el Menu, opción Solicitudes"), txtAceptar: .constant("Aceptar"), acceptAction: {
                    
                })
                .zIndex(1)
            }
        }
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
        
    func mensajeError(){
        toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
    }        
    
    func serverEnviarDatos(){
        
        // localizacion
        locationManager.getLocation()
        
        if(selectedOption == 0){
            toastViewModel.showCustomToast(with: "Seleccionar Tipo Solvencia", tipoColor: .gris)
            return
        }
        
        if nombre.isEmpty {
            toastViewModel.showCustomToast(with: "Nombre es requerido", tipoColor: .gris)
            return
        }
        
        if dui.isEmpty {
            toastViewModel.showCustomToast(with: "DUI es requerido", tipoColor: .gris)
            return
        }
        
        openLoadingSpinner = true
        viewModel.solvenciaCatastroRX(idToken: idToken, idCliente: idCliente, latitud: latitudFinal, longitud: longitudFinal, tipoSoli: selectedOption, nombre: nombre, dui: dui){ result in
            switch result {
                
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    // Datos enviados
                    toastViewModel.showCustomToast(with: "Datos Enviados", tipoColor: .verde)
                    selectedOption = 0
                    nombre = ""
                    dui = ""
                    popDatosEnviados = true
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
}


#Preview {
    SolvenciaCatastroView()
}
