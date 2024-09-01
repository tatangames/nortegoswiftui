//
//  ToolbarPrincipalView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 24/8/24.
//

import SwiftUI

struct ToolbarPrincipalView: View {
    @Binding var x : CGFloat
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation{
                        x = 0
                    }
                }){
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 24))
                        .foregroundColor(Color.blue)
                }
                
                Spacer(minLength: 0)
                
                Text("Servicios")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer(minLength: 0)
                
                // Espacio fijo igual al tamaño del botón para centrar el texto
                Button(action: {}) {
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 24))
                        .foregroundColor(.clear)
                }
                .disabled(true)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
        .contentShape(Rectangle())
        .background(Color.white)
    }
}


