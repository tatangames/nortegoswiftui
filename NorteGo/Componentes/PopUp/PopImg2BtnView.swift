//
//  PopVerificarView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 18/8/24.
//
// ** POP UP CON IMAGEN, MENSAJE, 2 BOTONES  **

import SwiftUI

struct PopImg2BtnView: View {
    @Binding var isActive: Bool
    @Binding var imagen: String
    @Binding var descripcion: String
    @Binding var txtCancelar: String
    @Binding var txtAceptar: String
            
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
                Image("infocolor")
                    .resizable()
                    .frame(width: 50, height: 50)
                                
                // Mensaje del modal
                Text(descripcion)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                   // .padding(.horizontal)
                
                HStack {
                    // Botón de Cancelar
                    Button(action: {
                        withAnimation {
                            cancelAction()
                            isActive = false
                        }
                    }) {
                        Text(txtCancelar)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(8)
                    }.buttonStyle(NoOpacityChangeButtonStyle())
                    
                    // Botón de Aceptar
                    Button(action: {
                        withAnimation {
                            acceptAction()
                            isActive = false
                        }
                    }) {
                        Text(txtAceptar)                          
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("cazulv1"))
                            .cornerRadius(8)
                    }.buttonStyle(NoOpacityChangeButtonStyle())
                }
               // .padding(.horizontal)
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
    PopImg2BtnView(isActive: .constant(true), imagen: .constant("infocolor"), descripcion: .constant("Verificar numero ejemplo de texto que se muestra en preview"), txtCancelar: .constant("Cancelar"), txtAceptar: .constant("Aceptar"), cancelAction: {}, acceptAction: {})
}
