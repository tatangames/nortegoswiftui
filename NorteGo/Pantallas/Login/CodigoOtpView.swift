//
//  CodigoOtpView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 20/8/24.
//
import SwiftUI
import SwiftyJSON
import RxSwift
import Alamofire
import AlertToast

struct CodigoOtpView: View {
    
    @Environment(\.presentationMode) var presentationMode
   
    let telefono: String
    @State private var localTelefono: String
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var popNumeroBloqueado: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var showToastBool: Bool = false
    @State private var otpCode: String = ""
    @State private var boolPantallaPrincipal: Bool = false
    @StateObject private var timerViewModel: TimerViewModel
    // una Vez reintento verificar numero
    @State private var boolApiVerificarSMS:Bool = true
    // una Vez reintento de enviar codigo
    @State private var boolApiReenvioSMS:Bool = true
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    private let disposeBag = DisposeBag()
    
    // constructor
    init(telefono: String, startValue: Int) {
        self.telefono = telefono
             _localTelefono = State(initialValue: telefono)
        
        _timerViewModel = StateObject(wrappedValue: TimerViewModel(initialTime: startValue))
    }
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 15){
                    
                    Image("mensaje")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 20)
                    
                    Text("Ingresa el código de 6 dígitos que enviamos a tu número de teléfono")
                        .foregroundColor(Color.black)
                        .font(.custom("Montserrat-Medium", size: 15))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    OTPInput(numberOfFields: 6, otpCode: $otpCode)
                        .padding(.top, 25)
                                        
                    Text(timerViewModel.tiempoSegundo == 0 ? "Reenviar Código" : "Reintentar en \(timerViewModel.tiempoSegundo)")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .padding()
                        .padding(.top, 20)
                        .foregroundColor(timerViewModel.tiempoSegundo == 0 ? .black : .gray)
                        .onTapGesture {
                            if timerViewModel.tiempoSegundo == 0 {
                                serverReenviarCodigo()
                            }
                        }
                        .onAppear {
                            // Iniciar el temporizador al aparecer la vista
                            timerViewModel.startTimer()
                        }
                    Button(action: { // btn verificar
                        // Acción para el botón ingresar
                        hideKeyboard()
                        
                        if otpCode.count < 6 {
                            showCustomToast(with: "Completar código")
                            return
                        }
                        
                        serverVerificarNumero()                        
                    }) {
                        Text("VERIFICAR")
                            .font(.custom("LiberationSans-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("cazulv1"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    .opacity(1.0)
                    .buttonStyle(NoOpacityChangeButtonStyle())
                }
                .padding(.bottom, keyboardHeight) // Ajusta la vista según la altura del teclado
                .onTapGesture {
                    hideKeyboard() // Oculta el teclado al tocar fuera
                }
                .navigationTitle("Verificación")
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
            }
            .onTapGesture {
                hideKeyboard()
            } //end-scroll
            
            // Pop-ups
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
    }
        
    
    //** FUNCIONES **/
    func serverVerificarNumero() {
        
        if boolApiVerificarSMS {
            boolApiVerificarSMS = false
            
            openLoadingSpinner = true
            
            let encodeURL = apiVerificarCodigo
            
            let parameters: [String: Any] = [
                "telefono": localTelefono,
                "codigo": otpCode,
                "idonesignal": ""
            ]
            
            Observable<Void>.create { observer in
                let request = AF.request(encodeURL, method: .post, parameters: parameters)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            openLoadingSpinner = false
                            boolApiVerificarSMS = true
                            
                            let json = JSON(data)
                            
                            if let successValue = json["success"].int {
                                
                                if(successValue == 1){
                                    // usuario bloqueado
                                    popNumeroBloqueado = true
                                }
                                else if(successValue == 2){
                                    
                                    // credenciales de acceso
                                    let _token = json["token"].string ?? ""
                                    let _id = json["id"].string ?? ""
                                    
                                    idToken = _token
                                    idUsuario = _id
                                    
                                    boolPantallaPrincipal = true
                                }
                                else if(successValue == 3){
                                    showCustomToast(with: "Código incorrecto")
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
                boolApiVerificarSMS = true
                openLoadingSpinner = false
                showCustomToast(with: "Error")
            })
            .disposed(by: disposeBag)
        }
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
    
    
    func serverReenviarCodigo() {
        
        if boolApiReenvioSMS {
            boolApiReenvioSMS = false
            
            openLoadingSpinner = true
            
            let encodeURL = apiReintentoSMS
            
            let parameters: [String: Any] = [
                "telefono": localTelefono
            ]
            
            Observable<Void>.create { observer in
                let request = AF.request(encodeURL, method: .post, parameters: parameters)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            openLoadingSpinner = false
                            boolApiReenvioSMS = true
                            
                            let json = JSON(data)
                            
                            if let successValue = json["success"].int {
                                
                                if(successValue == 1){
                                    // usuario bloqueado
                                    popNumeroBloqueado = true
                                }
                                else if(successValue == 2){
                                    
                                    // Reinicia a 60 segundos o el tiempo que desees
                                    timerViewModel.resetTimer(to: 60)
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
                boolApiReenvioSMS = true
                openLoadingSpinner = false
                showCustomToast(with: "Error")
            })
            .disposed(by: disposeBag)
        }
    }
    
}

/*#Preview {
 CodigoOtpView()
 }*/
