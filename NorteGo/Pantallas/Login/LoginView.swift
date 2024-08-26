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
    @State private var openLoadingSpinner = false
    @State private var boolApiLogin = true
    @State private var showToastBool = false
    
    @State private var boolPantallaOTP = false
    let disposeBag = DisposeBag()
        
    // variables que recibo del servidor, esto se modifican
    @State private var _segundosiphone = 60
    
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    
    var body: some View {
        
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
                    
                    // Phone Number Field with Prefix and Icon
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
                    
                    Button(action: { // btn ingresar
                        // Acción para el botón ingresar
                        hideKeyboard()
                        verificarNumeroDeTelefono()
                        
                        
                    }) {
                        Text("Ingresar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("cazulv1"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
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
                PopImg2BtnView(isActive: $popVerificar, imagen: .constant("infocolor"), descripcion: .constant("Verificar el número de teléfono"), txtCancelar: .constant("Editar"), txtAceptar: .constant("Verificar"), cancelAction: {}, acceptAction: {
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
        
        .toast(isPresenting: $showToastBool, duration: 3, tapToDismiss: false) {
            customToast
        }
        // pasara pantalla OTP donde se ingresa el codigo a verificar
        .fullScreenCover(isPresented: $boolPantallaOTP) {
            CodigoOtpView(initialTime: _segundosiphone, phoneNumber: phoneNumber)
        }
        
    } // end-body
    
    
    // ** FUNCIONES **
    
    // Función para configurar y mostrar el toast
    func showCustomToast(with mensaje: String) {
        // with backgroundColor: Color
        // Color("cazulv1")
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
        
        if boolApiLogin {
            boolApiLogin = false
            
            openLoadingSpinner = true
            
            let encodeURL = apiVerificarTelefono
            
            let parameters: [String: Any] = [
                "telefono": phoneNumber,
            ]
            
            Observable<Void>.create { observer in
                let request = AF.request(encodeURL, method: .post, parameters: parameters)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            openLoadingSpinner = false
                            boolApiLogin = true
                            
                            let json = JSON(data)
                            
                            if let successValue = json["success"].int {
                                
                                if(successValue == 1){
                                    // usuario bloqueado
                                    popNumeroBloqueado = true
                                }
                                else if(successValue == 2){
                                    
                                
                                    _segundosiphone = json["segundosiphone"].int ?? 0
                                    
                                    // pasar a siguiente pantalla
                                    boolPantallaOTP = true
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
                boolApiLogin = true
                openLoadingSpinner = false
                showCustomToast(with: "Error")
            })
            .disposed(by: disposeBag)
        }
    }
    
    
} // end-view




#Preview {
    LoginView()
}
