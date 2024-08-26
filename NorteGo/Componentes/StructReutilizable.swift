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



