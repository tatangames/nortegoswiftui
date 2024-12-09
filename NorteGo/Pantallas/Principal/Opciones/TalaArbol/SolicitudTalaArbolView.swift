//
//  SolicitudTalaArbolView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 28/8/24.
//

import SwiftUI
import PhotosUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast

struct SolicitudTalaArbolView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    
    @State var idServicio:Int = 0
    @State var tituloVista:String = ""
    @State private var selectedOption:Int = 1
    @State private var openLoadingSpinner:Bool = false
    @State private var showToastBool:Bool = false
    @State private var popDatosEnviados:Bool = false
    //** OPCIONES PARA SOLICITUD TALA ARBOL
    @State private var NombreCompleto:String = ""
    @State private var Telefono:String = ""
    @State private var Direccion:String = ""
    @State private var NotaOpcional:String = ""
    @State private var Escritura:Int = 0
    @State private var checkedEscritura:Bool = false
    @State var selectedImage:UIImage?
    @State var selectedItem:PhotosPickerItem? = nil
    @State private var isPickerPresented:Bool = false
    @State private var showSettingsAlert:Bool = false
    @State private var isCameraPresented:Bool = false
    @State private var sheetCamaraGaleria:Bool = false
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModelSolicitud = SolicitudTalaViewModel()
    @StateObject var viewModelDenuncia = DenunciaTalaViewModel()
    // GPS
    @State private var latitudFinal: String = ""
    @State private var longitudFinal: String = ""
    @StateObject private var locationManager = LocationManager()
    let disposeBag = DisposeBag()
    
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    VStack(alignment: .leading) { // Alinear a la izquierda
                        RadioButton(id: 1, label: "Solicitud Tala de Árbol", isSelected: $selectedOption)
                        RadioButton(id: 2, label: "Denuncia Tala de Árbol", isSelected: $selectedOption)
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 35)
                    
                    // Muestra la vista correspondiente a la opción seleccionada
                    if selectedOption == 1 {
                        
                        VistaSolicitudTala(NombreCompleto: $NombreCompleto, Telefono: $Telefono, Direccion: $Direccion, NotaOpcional: $NotaOpcional, Escritura: $Escritura)
                        
                        VistaFotografia(selectedImage: $selectedImage, NotaOpcional: $NotaOpcional,
                                        sheetCamaraGaleria: $sheetCamaraGaleria)
                        
                        Button(action: {
                            checkedEscritura.toggle()
                        }) {
                            HStack {
                                Image(systemName: checkedEscritura ? "checkmark.square.fill" : "square")
                                    .resizable() // Permite redimensionar la imagen
                                    .frame(width: 20, height: 20) // Tamaño del checkbox
                                    .foregroundColor(checkedEscritura ? .blue : .gray)
                                Text("¿Tiene Escritura?")
                                    .font(.custom("LiberationSans-Bold", size: 16))
                                    .foregroundColor(.black)
                            }
                        }  .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 45)
                        
                        
                    } else {
                        
                        VistaFotografia(selectedImage: $selectedImage, NotaOpcional: $NotaOpcional,
                                        sheetCamaraGaleria: $sheetCamaraGaleria)
                    }
                    
                    Button(action: { // btn ingresar
                        // Acción para el botón ingresar
                        
                        if selectedOption == 1{
                            serverSolicitudTalaArbol()
                        }else{
                            serverDenunciaTalaArbol()
                        }
                        
                    }) {
                        Text(selectedOption == 1 ? "Enviar Solicitud" : "Enviar Denuncia")
                            .font(.custom("LiberationSans-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.ColorAzulGob)
                            .cornerRadius(32)
                    }
                    .padding(.top, 60)
                    .opacity(1.0)
                    .buttonStyle(NoOpacityChangeButtonStyle())
                    
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Regresa a la pantalla anterior
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.black)// Ícono personalizado
                                Text("Atras")
                                    .foregroundColor(.black)// Texto personalizado
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
        .sheet(isPresented: $sheetCamaraGaleria) {
            BottomSheetCamaraGaleriaView(onOptionSelected: { option in
                
                if option == 1{
                    checkPhotoLibraryPermission()
                }else{
                    checkCameraPermission()
                }
                
                // actualizar localizacion aqui
                sheetCamaraGaleria = false // Cierra el bottom sheet
            })
        }
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                .onChange(of: selectedImage) { newImage in
                    /* if newImage != nil {
                     actualizaraImagen = true
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
        .onReceive(viewModelSolicitud.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onReceive(viewModelDenuncia.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
    
    func mensajeError(){
        toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
    }
    
    func serverSolicitudTalaArbol(){
        
        if NombreCompleto.isEmpty {
            toastViewModel.showCustomToast(with: "Nombre es requerido", tipoColor: .gris)
            return
        }
        
        if Telefono.isEmpty {
            toastViewModel.showCustomToast(with: "Teléfono es requerido", tipoColor: .gris)
            return
        }
        
        if Direccion.isEmpty {
            toastViewModel.showCustomToast(with: "Dirección es requerido", tipoColor: .gris)
            return
        }
        
        guard selectedImage != nil else {
            toastViewModel.showCustomToast(with: "Seleccionar Imagen", tipoColor: .gris)
            return
        }
        
        openLoadingSpinner = true
        
        var valorEscritura = 0
        if(checkedEscritura){
            valorEscritura = 1
        }
        
        viewModelSolicitud.enviarSolicitudTalaRX(idToken: idToken, idCliente: idCliente, nombre: NombreCompleto, telefono: Telefono, direccion: Direccion, escritura: valorEscritura, nota: NotaOpcional, latitud: latitudFinal, longitud: longitudFinal, selectedImage: selectedImage){ result in
            switch result {
                
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    // DATOS GUARDADOS
                    toastViewModel.showCustomToast(with: "Información Enviada", tipoColor: .verde)
                    selectedImage = nil
                    NombreCompleto = ""
                    Telefono = ""
                    Direccion = ""
                    NotaOpcional = ""
                    checkedEscritura = false
                    popDatosEnviados = true
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    
    func  serverDenunciaTalaArbol(){
        
        locationManager.getLocation()
        
        guard selectedImage != nil else {
            toastViewModel.showCustomToast(with: "Seleccionar Imagen", tipoColor: .gris)
            return
        }
        
        openLoadingSpinner = true
        
        viewModelDenuncia.enviarDenunciaTalaRX(idToken: idToken, idCliente: idCliente, nota: NotaOpcional, latitud: latitudFinal, longitud: longitudFinal, selectedImage: selectedImage){ result in
            switch result {
                
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    
                    // DATOS GUARDADOS
                    toastViewModel.showCustomToast(with: "Información Enviada", tipoColor: .verde)
                    selectedImage = nil
                    NotaOpcional = ""
                    popDatosEnviados = true
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
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
            print("Camara no disponible")
        }
    }
}


// Definiciones de vistas para cada opción
struct VistaSolicitudTala: View {
    
    @Binding var NombreCompleto: String
    @Binding var Telefono: String
    @Binding var Direccion: String
    @Binding var NotaOpcional: String
    @Binding var Escritura: Int
    
    var body: some View {
        
        // Alinea el texto a la izquierda
        HStack {
            Text("Nombre Completo")
                .bold()
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, 35)
        
        VStack {
            TextField("Nombre", text: $NombreCompleto)
                .onChange(of: NombreCompleto) { newValue in
                    if newValue.count > 100 {
                        NombreCompleto = String(newValue.prefix(100))
                    }
                }
                .padding(.bottom, 0) // Añade espacio entre el texto y la línea
            
            // Línea subrayada
            Rectangle()
                .frame(height: 1) // Altura de la línea
                .foregroundColor(.gray) // Color de la línea
            
            
            HStack {
                Text("Teléfono")
                    .bold()
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.top, 30)
            
            TextField("Teléfono", text: $Telefono)
                .keyboardType(.phonePad)
                .onChange(of: Telefono) { newValue in
                    if newValue.count > 8 {
                        Telefono = String(newValue.prefix(8))
                    }
                }
                .padding(.bottom, 0) // Añade espacio entre el texto y la línea
            
            // Línea subrayada
            Rectangle()
                .frame(height: 1) // Altura de la línea
                .foregroundColor(.gray) // Color de la línea
            
            HStack {
                Text("Dirección")
                    .bold()
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.top, 30)
            
            TextField("Dirección", text: $Direccion)
                .onChange(of: Direccion) { newValue in
                    if newValue.count > 500 {
                        Direccion = String(newValue.prefix(500))
                    }
                }
                .padding(.bottom, 0) // Añade espacio entre el texto y la línea
            
            // Línea subrayada
            Rectangle()
                .frame(height: 1) // Altura de la línea
                .foregroundColor(.gray) // Color de la línea
        }
    }
}

struct VistaFotografia: View {
    
    @Binding var selectedImage:UIImage?
    @Binding var NotaOpcional: String
    @Binding var sheetCamaraGaleria:Bool
    
    var body: some View {
        
        HStack {
            Text("Imagen del Árbol")
                .bold()
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, 30)
        
        Button(action: {
            // Abrir bottom sheet
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
        
        HStack {
            Text("Nota (Opcional)")
                .bold()
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, 45)
        
        VStack {
            TextField("Nota", text: $NotaOpcional)
                .onChange(of: NotaOpcional) { newValue in
                    if newValue.count > 1000 {
                        NotaOpcional = String(newValue.prefix(1000))
                    }
                }
                .padding(.bottom, 0) // Añade espacio entre el texto y la línea
            
            // Línea subrayada
            Rectangle()
                .frame(height: 1) // Altura de la línea
                .foregroundColor(.gray) // Color de la línea
        }
    }
}

struct VistaDenunciaTala: View {
    var body: some View {
        Text("Vista de Solvencia de Empresa")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
            .cornerRadius(10)
            .padding()
    }
}


struct SolicitudTalaArvolView_Previews: PreviewProvider {
    static var previews: some View {
        SolicitudTalaArbolView()
    }
}
