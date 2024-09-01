//
//  SideMenuView.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 22/8/24.
//

import SwiftUI

struct SideMenuView: View {
    
    var edges: UIEdgeInsets? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                return window.safeAreaInsets
            }
        }
        return nil
    }
    
    @State var show = true
    @State private var selectedMenu: SideMenuOptionModel? // = .servicios
    @Binding var x: CGFloat
    @Binding var popCerrarSesion: Bool
    
    
    var body: some View {
        
        HStack {
            VStack{
                
                SideMenuHeaderView()
                    .frame(height: 60)
                    .background(Color("cazulv1"))
                
                VStack(alignment: .leading){
                    
                    ScrollView{
                        ForEach(SideMenuOptionModel.allCases) { menu in
                            if menu == .cerrarsesion {
                                Button(action: {
                                    popCerrarSesion = true
                                    closeMenu()
                                }) {
                                    SideMenuRowView(
                                        title: menu.title,
                                        imagen: menu.systemImageName,
                                        isSelected: selectedMenu == menu
                                    )
                                }
                            } else {
                                NavigationLink(destination: destinationView(for: menu)) {
                                    SideMenuRowView(
                                        title: menu.title,
                                        imagen: menu.systemImageName,
                                        isSelected: selectedMenu == menu
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    selectedMenu = menu
                                    closeMenu()
                                })
                            }
                        }
                        .padding(.horizontal, 10)
                        
                    }.frame(maxHeight: .infinity)
                    
                    Spacer(minLength: 0)
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack {
                        Text("v. 1.0")
                    }
                    
                    .opacity(show ? 1 : 0)
                    .frame(height: show ? nil : 0)
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, edges!.top == 0 ? 15 : edges?.top)
            .padding(.bottom, edges!.bottom == 0 ? 15 : edges?.bottom)
            // default width
            .frame(width: UIScreen.main.bounds.width - 90)
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .vertical)
            Spacer(minLength: 0)
        }
    }
    
    private func closeMenu() {
        withAnimation {
            x = -UIScreen.main.bounds.width + 90
        }
    }
    
    @ViewBuilder
    func destinationView(for menu: SideMenuOptionModel) -> some View {
        
        switch menu {
        case .solicitudes:
            ListadoSolicitudesView()
        default:
            EmptyView()
        }
    }
}
