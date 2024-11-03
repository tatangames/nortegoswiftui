//
//  SplashScreenView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 16/8/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var showModal = false
    // recuperar token
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    
    var body: some View {
        
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            Image("logo").resizable().scaledToFit()
                .padding()
                .frame(width: 225, height: 225)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showModal = true
                }
            }
        }
        .fullScreenCover(isPresented: $showModal) {
            if idToken.isEmpty {
                LoginView()
            } else {
                PrincipalView()
            }
        }
        .background(Color.white)
    } // end-body
}

#Preview {
    SplashScreenView()
}
