//
//  CardView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 26/8/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

// ESTRUCTURA DE CADA OPCION CARDVIEW
struct CardView: View {
    var image: String
    var title: String
    var onTap: () -> Void
    var body: some View {
        VStack {
            
            WebImage(url: URL(string: baseUrlImagen + image))
                .resizable()
                .indicator(.activity)
                .scaledToFit()
                .frame(height: 100)
                .padding(.top, 10)
            
            Text(title)
                .font(.headline)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            
            
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 10)
        .onTapGesture {
            onTap()
        }
    }
}
