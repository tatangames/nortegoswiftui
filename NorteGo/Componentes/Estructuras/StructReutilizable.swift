//
//  StructReutilizable.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 18/8/24.
//

import Foundation
import SwiftUI
import AlertToast

// utilizado en login (ejemplo)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// ocultar teclado
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

// utilizado en login (ejemplo)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// Animacion cuando el boton es presionado
struct NoOpacityChangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0) // Mantener la opacidad al 100% incluso cuando se presiona
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Ejemplo de escala para indicar que está presionado
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}



struct RadioButton: View {
    let id: Int
    let label: String
    @Binding var isSelected: Int
    
    var body: some View {
        Button(action: {
            isSelected = id
        }) {
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected == id {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10) // Círculo más pequeño
                    }
                }
                Text(label)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}



enum ToastColor {
    case azul
    case verde
    case gris
    case rojo
    
    var color: Color {
        switch self {
        case .azul:
            return AppColors.ColorAzulGob
        case .verde:
            return AppColors.ColorVerde
        case .gris:
            return AppColors.ColorGris1Gob
        case .rojo:
            return AppColors.ColorRojo
        }
    }
}



extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
}
