//
//  SideMenuHeaderView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 22/8/24.
//

import SwiftUI

struct SideMenuHeaderView: View {
    var body: some View {        
        VStack {
            
            Text("NorteGo")
                .font(.custom("LiberationSans-Bold", size: 28))
                .foregroundColor(.white)
            
        }
        .frame(maxWidth: .infinity, maxHeight: 80) // Ajustar el tamaño del encabezado
        .background(AppColors.ColorAzulGob)
        .foregroundColor(.blue) // Asegura que el color del texto sea blanco
        .multilineTextAlignment(.center) // Alineación del texto en el centro
    }
}

#Preview {
    SideMenuHeaderView()
}
