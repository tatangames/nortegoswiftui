//
//  SideMenuOptionModel.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 22/8/24.
//

import Foundation

enum SideMenuOptionModel: Int, CaseIterable {
    case solicitudes
    case cerrarsesion
    
    var title: String {
        switch self {
      
        case .solicitudes:
            return "Solicitudes"
        case .cerrarsesion:
            return "Cerrar Sesión"       
        }
    }
    
    var systemImageName: String {
        switch self {
        case .solicitudes:
            return "list.bullet.rectangle"
        case .cerrarsesion:
            return "rectangle.portrait.and.arrow.right"
        }
    }
}

extension SideMenuOptionModel: Identifiable {
    var id: Int { return self.rawValue }
}
