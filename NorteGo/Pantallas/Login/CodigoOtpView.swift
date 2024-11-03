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
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
   
    let telefono: String
    @State private var localTelefono: String
    @State private var keyboardHeight: CGFloat = 0
    @State private var popNumeroBloqueado: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var showToastBool: Bool = false
    @State private var otpCode: String = ""
    @State private var boolPantallaPrincipal: Bool = false
    
    @StateObject private var timerViewModel: TimerViewModel
    @StateObject private var toastViewModel = ToastViewModel()
    let viewModel = CodigoOtpViewModel()
    let viewModelReenvio = CodigoOtpReenvioSmsViewModel()
    private let disposeBag = DisposeBag()
    
    // constructor
    init(telefono: String, startValue: Int) {
        self.telefono = telefono
             _localTelefono = State(initialValue: telefono)
        
        _timerViewModel = StateObject(wrappedValue: TimerViewModel(initialTime: startValue))
    }

    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 15) {
                        Image("mensaje")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.top, 20)
                        
                        Text("Ingresa el código de 6 dígitos que enviamos a tu número de teléfono: \(localTelefono)")
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
                            hideKeyboard()
                            
                            if otpCode.count < 6 {
                                toastViewModel.showCustomToast(with: "Completar código", tipoColor: .gris)
                                return
                            }
                            
                            serverVerificarNumero()
                        }) {
                            Text("VERIFICAR")
                                .font(.custom("LiberationSans-Bold", size: 17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.ColorAzulGob)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 50)
                        .opacity(1.0)
                        .buttonStyle(NoOpacityChangeButtonStyle())
                    }
                    .padding(.bottom, keyboardHeight)
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .navigationTitle("Verificación")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
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
                }
                
                // Pop-ups
                if popNumeroBloqueado {
                    PopImg1BtnView(isActive: $popNumeroBloqueado, imagen: .constant("infocolor"), bLlevaTitulo: .constant(true), titulo: .constant("Bloqueado"), descripcion: .constant("Número de teléfono bloqueado, contactar a la Administración"), txtAceptar: .constant("Aceptar"), acceptAction: {})
                        .zIndex(1)
                }
                
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .onReceive(viewModel.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
            .onReceive(viewModelReenvio.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
            .navigationDestination(isPresented: $boolPantallaPrincipal) {
                PrincipalView()
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden)
            }
            .background(Color.white)
            .toast(isPresenting: $toastViewModel.showToastBool, alert: {
                toastViewModel.customToast
            })
        }
    }
        
    
    //** FUNCIONES **/
    func serverVerificarNumero() {
        openLoadingSpinner = true
        viewModel.VerificarCodigoRX(telefono: telefono, codigo: otpCode, idonesignal: "")
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    
                                        
                    switch success {
                    case 1:
                        // verificacion correcta
                        let _token = json["token"].string ?? ""
                        let _id = json["id"].string ?? ""
                        
                        idToken = _token
                        idUsuario = _id
                        boolPantallaPrincipal = true
                    case 2:
                        
                        // codigo incorrecto
                        toastViewModel.showCustomToast(with: "Código incorrecto", tipoColor: .gris)
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
   
    
    func serverReenviarCodigo() {
        openLoadingSpinner = true
        viewModelReenvio.reenvioSMSRX(telefono: telefono)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                                        
                    switch success {
                    case 1:
                        // numero bloqueado
                        popNumeroBloqueado = true
                    case 2:
                        // error enviar sms
                        toastViewModel.showCustomToast(with: "Error enviar SMS", tipoColor: .gris)
                    case 3:
                        // enviado
                        toastViewModel.showCustomToast(with: "Enviado", tipoColor: .verde)
                        timerViewModel.resetTimer(to: 60)
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
    
}

/*#Preview {
 CodigoOtpView()
 }*/
