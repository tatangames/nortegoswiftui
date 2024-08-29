//
//  DenunciaBasicaView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 22/8/24.
//

import SwiftUI

struct DenunciaBasicaView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        
        VStack {
            Text("denuncia basica")
        }
        .navigationTitle("Detalle")
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
    }
}

#Preview {
    DenunciaBasicaView()
}
