//
//  ListadoServiciosView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 26/8/24.
//

import SwiftUI

struct ListadoServiciosView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
    
        VStack {
                   Text("listado servios")
               }
               .navigationTitle("Solicitudes")
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
    ListadoServiciosView()
}
