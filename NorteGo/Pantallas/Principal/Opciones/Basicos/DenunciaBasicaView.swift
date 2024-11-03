//
//  DenunciaBasicaView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 22/8/24.
//

import SwiftUI
import PhotosUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast

struct DenunciaBasicaView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente: String = ""
    
    @State var idServicio: Int = 0
    @State var tituloVista: String = ""
    @State private var showToastBool:Bool = false
    @State private var selectedImage:UIImage?
    @State private var selectedItem:PhotosPickerItem? = nil
    @State private var isPickerPresented:Bool = false
    @State private var showSettingsAlert:Bool = false
    @State private var isCameraPresented:Bool = false
    @State private var sheetCamaraGaleria:Bool = false
    @State private var notaOpcional:String = ""
    @State private var openLoadingSpinner:Bool = false
    @State private var latitudFinal:String = ""
    @State private var longitudFinal:String = ""
    @State private var popRangoDenunciaPendiente:Bool = false
    @State private var popDatosEnviados:Bool = false
    @StateObject private var toastViewModel = ToastViewModel()
    
    // cuando una solicitud esta pendiente en un rango segun server
    @State private var tituloRango: String = ""
    @State private var mensajeRango: String = ""
    @State var descripcion:String = ""
    
    // GPS
    @StateObject private var locationManager = LocationManager()
    @StateObject var viewModel = DenunciaBasicaViewModel()
    
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    if !descripcion.isEmpty {
                        HStack {
                            Text(descripcion)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(.top, 30)
                        .padding(.horizontal, 0)
                    }
                    
                    HStack {
                        Text("Seleccionar Imagen")
                            .bold()
                    }
                    .padding(.top, 35)
                    
                    Button(action: {
                        // Abrir bottom sheet
                        locationManager.getLocation() // gps
                        sheetCamaraGaleria.toggle()
                    }) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        } else {
                            Image("camarafoto")
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Alinea el texto a la izquierda
                    HStack {
                        Text("Nota (Opcional)")
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    VStack {
                        TextField("Nota", text: $notaOpcional)
                            .onChange(of: notaOpcional) { newValue in
                                if newValue.count > 1000 {
                                    notaOpcional = String(newValue.prefix(1000))
                                }
                            }
                            .padding(.bottom, 0) // Añade espacio entre el texto y la línea
                        
                        // Línea subrayada
                        Rectangle()
                            .frame(height: 1) // Altura de la línea
                            .foregroundColor(.gray) // Color de la línea
                    }
                    
                    Button(action: { // btn verificar
                        serverSubirInformacion()
                    }) {
                        Text("ENVIAR")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.ColorAzulGob)
                            .cornerRadius(32)
                    }
                    .padding(.top, 50)
                    .opacity(1.0)
                    .buttonStyle(NoOpacityChangeButtonStyle())
                    
                    Spacer()
                }
                
                .padding()
                .photosPicker(isPresented: $isPickerPresented, selection: $selectedItem, matching: .images)
                
                .onChange(of: selectedItem) { newItem in
                    if let newItem = newItem {
                        newItem.loadTransferable(type: Data.self) { result in
                            switch result {
                            case .success(let data):
                                if let data = data, let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            case .failure(let error):
                                print("Error loading image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                
                .navigationTitle(tituloVista)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
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
            
            // Pop-up numero bloqueado
            if popRangoDenunciaPendiente {
                PopImg1BtnView(isActive: $popRangoDenunciaPendiente, imagen: .constant("infocolor"), bLlevaTitulo: .constant(true), titulo: $tituloRango, descripcion: $mensajeRango, txtAceptar: .constant("Aceptar"), acceptAction: {
                    
                })
                .zIndex(1)
            }
            
            // pop datos enviados
            if popDatosEnviados {
                PopImg1BtnView(isActive: $popDatosEnviados, imagen: .constant("infocolor"), bLlevaTitulo: .constant(true), titulo: .constant("Enviado"), descripcion: .constant("Puede verificar la solicitud en el Menu, opción Solicitudes"), txtAceptar: .constant("Aceptar"), acceptAction: {
                    
                })
                .zIndex(1)
            }
        }
        .sheet(isPresented: $sheetCamaraGaleria) {
            BottomSheetCamaraGaleriaView(onOptionSelected: { option in
                
                if option == 1{
                    checkPhotoLibraryPermission()
                }else{
                    checkCameraPermission()
                }
                
                sheetCamaraGaleria = false // Cierra el bottom sheet
            })
        }
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                .onChange(of: selectedImage) { newImage in
                    /* if newImage != nil {
                     
                     }*/
                }
        }
        .alert(isPresented: $showSettingsAlert) {
            Alert(
                title: Text("Acceso a Galería y Camara Denegado"),
                message: Text("Por favor habilitar el permiso de Galería y Camara en Ajustes."),
                primaryButton: .default(Text("Ajustes")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .default(Text("Cancelar")) {
                }
            )
        }
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
        
    } // end-body
    
    
    
    func serverSubirInformacion() {
        
        locationManager.getLocation()
        
        guard let image = selectedImage else {
            toastViewModel.showCustomToast(with: "Seleccionar Imagen", tipoColor: .gris)
            return
        }

        viewModel.enviarDenunciaBasicaRX(idToken: idToken, idCliente: idCliente, idServicio: idServicio, nota: notaOpcional, latitud: latitudFinal, longitud: longitudFinal, selectedImage: selectedImage){ result in
            switch result {
                
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    // HAY SOLICITUD ACTIVA, Y ESTA DENTRO DEL RANGO x METROS
                    let _titulo = json["titulo"].string ?? ""
                    let _mensaje = json["mensaje"].string ?? ""
                    
                    tituloRango = _titulo
                    mensajeRango = _mensaje
                    popRangoDenunciaPendiente = true
                case 2:
                    toastViewModel.showCustomToast(with: "Solicitud recibida", tipoColor: .verde)
                    selectedImage = nil
                    notaOpcional = ""
                    popDatosEnviados = true
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
    
    
    // verificar permiso para galeria
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //print("Permiso autorizado")
            isPickerPresented = true
        case .denied, .restricted:
            //print("Permiso denegado o restrictivo")
            showSettingsAlert = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    //print("Acceso autorizado despues del request")
                    isPickerPresented = true
                } else {
                    //print("Accesso denegado despues del request")
                    showSettingsAlert = true
                }
            }
        case .limited:
            showSettingsAlert = true
        @unknown default:
            // print("Estado desconocido")
            showSettingsAlert = true
        }
    }
    
    func checkCameraPermission() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                isCameraPresented = true
            case .denied, .restricted:
                showSettingsAlert = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        isCameraPresented = true
                    } else {
                        showSettingsAlert = true
                    }
                }
            @unknown default:
                showSettingsAlert = true
            }
        } else {
            print("Cámara no disponible")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DenunciaBasicaView()
    }
}
