//
//  PopVerificarView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 18/8/24.
//
// ** PARA PANTALLA LOGIN, VERIFICAR NUMERO **

import SwiftUI

struct PopVerificarView: View {
    @Binding var isActive: Bool
    var title: String
    var message: String
    var cancelAction: () -> Void
    var acceptAction: () -> Void
    
    var body: some View {
        ZStack {
            // Fondo semi-transparente
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isActive = false
                    }
                }
            
            // Contenedor del modal
            VStack(spacing: 20) {
                // Título del modal
                Image("")
                
                // Mensaje del modal
                Text(message)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    // Botón de Cancelar
                    Button(action: {
                        withAnimation {
                            cancelAction()
                            isActive = false
                        }
                    }) {
                        Text("Cancelar")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // Botón de Aceptar
                    Button(action: {
                        withAnimation {
                            acceptAction()
                            isActive = false
                        }
                    }) {
                        Text("Aceptar")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
    }
}


#Preview {
    PopVerificarView(isActive: .constant(true), title: "Titulo", message: "verificar numero", cancelAction: {}, acceptAction: {})
}
