//
//  VistaLoginView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 16/8/24.
//

import SwiftUI
import SwiftyJSON
import RxSwift
import Alamofire
import AlertToast

struct LoginView: View {
    
    @State private var phoneNumber: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var popNumRequerido: Bool = false
    @State private var popNumCorto: Bool = false
    @State private var popVerificar: Bool = false
    @State private var popNumeroBloqueado: Bool = false
    @State private var openLoadingSpinner:Bool = false
    @State private var showToastBool:Bool = false
    @State private var boolCambiarVista = false
    @State private var segundos = 60
    @StateObject private var toastViewModel = ToastViewModel()
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 15){
                        // Logo
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .padding(.top, 50)
                        
                        Text("NorteGo")
                            .font(.custom("LiberationSans-Bold", size: 28))
                        
                       
                        HStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                                    .frame(height: 44)
                                
                                HStack {
                                    Image("elsalvador")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding(.leading, 8)
                                    
                                    Text("+503")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 0)
                                    
                                    TextField("Número de teléfono", text: $phoneNumber)
                                        .keyboardType(.numberPad)
                                        .onChange(of: phoneNumber) { newValue in
                                            // Formatear el número
                                            let filtered = newValue.filter { $0.isNumber }
                                            let formatted = formatNumber(filtered)
                                            phoneNumber = formatted
                                        }
                                        .padding(12)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 25)
                        
                        Button(action: {
                            hideKeyboard()
                            verificarNumeroDeTelefono()
                            }) {
                            Text("VERIFICAR")
                                .font(.custom("LiberationSans-Bold", size: 17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.ColorAzulGob)
                                .cornerRadius(32)
                        }
                        .padding(.horizontal)
                        .padding(.top, 30)
                        .opacity(1.0)
                        .buttonStyle(NoOpacityChangeButtonStyle())
                    }
                    .padding(.bottom, keyboardHeight) // Ajusta la vista según la altura del teclado
                    .onTapGesture {
                        hideKeyboard() // Oculta el teclado al tocar fuera
                    }
                    .onAppear {
                        // Observa la notificación del teclado
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                withAnimation(.easeOut(duration: 0.16)) {
                                    keyboardHeight = keyboardFrame.height
                                }
                            }
                        }
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                            withAnimation(.easeOut(duration: 0.16)) {
                                keyboardHeight = 0
                            }
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self)
                    }
                    
                }.onTapGesture {
                    hideKeyboard()
                } //end-scroll
                
                
                // Pop-up numero es requerido
                if popNumRequerido {
                    PopImg1BtnView(isActive: $popNumRequerido, imagen: .constant("infocolor"), bLlevaTitulo: .constant(false), titulo: .constant(""), descripcion: .constant("Teléfono es requerido"), txtAceptar: .constant("Aceptar"), acceptAction: {})
                        .zIndex(1)
                }
                
                // Pop-up numero es corto
                if popNumCorto {
                    PopImg1BtnView(isActive: $popNumCorto, imagen: .constant("infocolor"), bLlevaTitulo: .constant(false), titulo: .constant("Nota"), descripcion: .constant("El teléfono introducido es demasiado corto"), txtAceptar: .constant("Editar"), acceptAction: {})
                        .zIndex(1)
                }
                
                // Pop-up verificar numero de telefono
                if popVerificar {
                    PopImg2BtnView(isActive: $popVerificar, imagen: .constant("infocolor"), descripcion: .constant("¿El número \(phoneNumber) introducido es correcto?"), txtCancelar: .constant("Cancelar"), txtAceptar: .constant("Verificar"), cancelAction: {}, acceptAction: {
                        serverLogin()
                    }).zIndex(1)
                }
                
                // Pop-up numero bloqueado
                if popNumeroBloqueado {
                    PopImg1BtnView(isActive: $popNumeroBloqueado, imagen: .constant("infocolor"), bLlevaTitulo: .constant(true), titulo: .constant("Bloqueado"), descripcion: .constant("Número de teléfono bloqueado, contactar a la Administración"), txtAceptar: .constant("Aceptar"), acceptAction: {})
                        .zIndex(1)
                }
                
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity) // Transición de opacidad
                        .zIndex(10)
                }
            } // end-zstack
        
            .navigationDestination(isPresented: $boolCambiarVista) {
                CodigoOtpView(telefono: phoneNumber, startValue: segundos)
            }
            .onReceive(viewModel.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
            .background(Color.white)
          
        } // end-navigationStack
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    } // end-body
    
    
    func verificarNumeroDeTelefono() -> Void {
        if phoneNumber.isEmpty {
            popNumRequerido = true
            return
        }
        
        if phoneNumber.count < 9 {
            popNumCorto = true
            return
        }
        
        popVerificar = true
    }
    
    // Función para formatear el número
    private func formatNumber(_ number: String) -> String {
        let maxLength = 8
        let chunkSize = 4
        let limit = min(number.count, maxLength)
        
        var result = ""
        var start = number.startIndex
        
        while start < number.index(number.startIndex, offsetBy: limit) {
            let end = number.index(start, offsetBy: chunkSize, limitedBy: number.endIndex) ?? number.endIndex
            let chunk = number[start..<end]
            if !result.isEmpty {
                result.append(" ")
            }
            result.append(contentsOf: chunk)
            start = end
        }
        return result
    }    
    
    func serverLogin(){
        
        viewModel.verificarTelefonoRX(telefono: phoneNumber)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                                        
                    switch success {
                    case 1:
                        // numero bloqueado
                        popNumeroBloqueado = true
                    case 2:
                       // error al enviar sms
                        toastViewModel.showCustomToast(with: "Error enviar el SMS", tipoColor: .gris)
                    case 3:
                        
                        let _segundos = json["segundos"].int ?? 0
                        segundos = _segundos
                        
                        // respuesta correcta
                        boolCambiarVista = true
                    case 100:
                        // solo para desarrollo
                        toastViewModel.showCustomToast(with: "Aplicación en Desarrollo", tipoColor: .gris)
                    default:
                       mensajeError()
                    }
                    
                case .failure(_):
                    mensajeError()
                }
            }, onError: { error in
                mensajeError()
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    func mensajeError(){
        toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
    }
    
} // end-view
