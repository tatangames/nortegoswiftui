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
    
    @State var tituloVista: String = ""
    @State private var selectedOption: Int = 0
    
    @State private var showToastBool:Bool = false
    @State private var nombre:String = ""
    @State private var dui:String = ""
    @State private var openLoadingSpinner:Bool = false
    @StateObject private var locationManager = LocationManager()
    @State private var latitudFinal:String = ""
    @State private var longitudFinal:String = ""
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @State private var popDatosEnviados:Bool = false
    let disposeBag = DisposeBag()
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
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
                            .background(Color("cazulv1"))
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
                                Text("Atras") // Texto personalizado
                            }
                        }
                    }
                }
                .onChange(of: locationManager.latitude) { newLatitude in
                    latitudFinal = String(format: "%.6f", newLatitude)
                }
                .onChange(of: locationManager.longitude) { newLongitude in
                    longitudFinal = String(format: "%.6f", newLongitude)
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
        
        .toast(isPresenting: $showToastBool, duration: 3, tapToDismiss: false) {
            customToast
        }
    }
    
    
    // Función para configurar y mostrar el toast
    func showCustomToast(with mensaje: String, tipoColor: Int) {
        
        let titleColor: Color
        
        if tipoColor == 1 {
            titleColor = Color("ColorAzulToast")
        } else {
            titleColor = Color("cverde")
        }
        
        customToast = AlertToast(
            displayMode: .banner(.pop),
            type: .regular,
            title: mensaje,
            subTitle: nil,
            style: .style(
                backgroundColor: titleColor,
                titleColor: Color.white,
                subTitleColor: Color.blue,
                titleFont: .headline,
                subTitleFont: nil
            )
        )
        showToastBool = true
    }
    
    
    func serverEnviarDatos(){
        
        // localizacion
        locationManager.requestLocation()
        
        if(selectedOption == 0){
            showCustomToast(with: "Seleccionar Tipo Solvencia", tipoColor: 1)
            return
        }
        
        if nombre.isEmpty {
            showCustomToast(with: "Nombre es requerido", tipoColor: 1)
            return
        }
        
        if dui.isEmpty {
            showCustomToast(with: "DUI es requerido", tipoColor: 1)
            return
        }
        
        openLoadingSpinner = true
        
        let encodeURL = apiEnviarDatosCatastro
        
        let parameters: [String: Any] = [
            "id": idCliente,
            "latitud": latitudFinal,
            "longitud": longitudFinal,
            "tiposoli": selectedOption,
            "nombre": nombre,
            "dui": dui
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)"
        ]
        
        Observable<Void>.create { observer in
            let request = AF.request(encodeURL, method: .post, parameters: parameters, headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        
                        openLoadingSpinner = false
                        
                        let json = JSON(data)
                        
                        if let successValue = json["success"].int {
                            
                            if(successValue == 1){
                                
                                // Datos enviados
                                showCustomToast(with: "Datos Enviados", tipoColor: 2)
                                selectedOption = 0
                                nombre = ""
                                dui = ""
                                popDatosEnviados = true
                                
                            }
                            else{
                                showCustomToast(with: "Error", tipoColor: 1)
                            }
                            
                        }else{
                            showCustomToast(with: "Error", tipoColor: 1)
                        }
                        
                    case .failure(_):
                        openLoadingSpinner = false
                        showCustomToast(with: "Error", tipoColor: 1)
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
            openLoadingSpinner = false
            showCustomToast(with: "Error", tipoColor: 1)
        })
        .disposed(by: disposeBag)
    }
}




#Preview {
    SolvenciaCatastroView()
}
