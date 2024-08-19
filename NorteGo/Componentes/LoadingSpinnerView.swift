//
//  LoadingView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 17/8/24.
//

import SwiftUI

struct LoadingSpinnerView: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
                  // Fondo semi-transparente
                  Color.black.opacity(0.4)
                      .edgesIgnoringSafeArea(.all)
                  
                  // Contenedor del indicador de carga
                  VStack(spacing: 20) {
                      // Indicador de actividad circular personalizado
                      Circle()
                          .trim(from: 0.0, to: 0.7)
                          .stroke(Color.blue, lineWidth: 4) // Grosor reducido a 4
                          .frame(width: 50, height: 50)
                          .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                          .onAppear {
                              withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                  isAnimating = true
                              }
                          }
                      
                      // Texto de carga
                      Text("Cargando...")
                          .foregroundColor(.black)
                          .font(.headline)
                  }
                  .padding(30)
                  .background(Color.white.opacity(0.8))
                  .cornerRadius(10)
                  .shadow(radius: 10)
              }
    }
}
#Preview {
    LoadingSpinnerView()
}
