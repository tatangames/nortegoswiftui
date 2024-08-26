//
//  Lista.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 17/8/24.
//

import SwiftUI

struct ListaView: View {
    
    var pokemons = [
        Pokemon(name: "pikachu"),
        Pokemon(name: "charizard")
    ]

    var digimons = [
        Digimon(name: "agumos"),
        Digimon(name: "sautumon"),
    ]
    
    @State var isActive: Bool = false
    
    var body: some View {
        
        ZStack{
                    VStack {
                        Button {
                            isActive = true
                        } label: {
                            Text("Mostrar pop up")
                        }
                    }
                    .padding()
                    
                    if isActive {
                        CustomModalView(isActive: $isActive, title: "Confirmar", message: "Mensaje de prueba", buttonTitle: "Hola mundo") {
                            // Acción a realizar cuando el botón se presiona
                            isActive = false // Cerrar el popup y volver a false
                        }
                    }
                }
    }
    
    struct CustomModalView: View {
        @Binding var isActive: Bool
        var title: String
        var message: String
        var buttonTitle: String
        var action: () -> Void
        
        var body: some View {
            VStack {
                Text(title)
                    .font(.headline)
                Text(message)
                    .padding()
                
                Button {
                    action()
                    isActive = false // Asegúrate de cerrar el popup
                } label: {
                    Text(buttonTitle)
                }
                .padding()
            }
            .frame(width: 300, height: 200)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
    
    struct Pokemon{
        let name: String
    }

    struct Digimon: Identifiable{
        var id = UUID()
        let name: String
    }
}

#Preview {
    ListaView()
}
