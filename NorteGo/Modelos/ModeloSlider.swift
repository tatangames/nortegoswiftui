//
//  ModeloSlider.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 25/8/24.
//

import Foundation

class ModeloSlider: Identifiable{
    var id: Int
    var imagen: String
    
    init(id: Int, imagen: String) {
        self.id = id
        self.imagen = imagen
    }
}
