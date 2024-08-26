//
//  ModeloTipoServicioArray.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 25/8/24.
//

import Foundation

class ModeloTipoServicioArray{
    
    var id: Int
    var nombre: String
    var lista: [ModeloTipoServicio]
    
    init(id: Int, nombre: String, lista: [ModeloTipoServicio]) {
        self.id = id
        self.nombre = nombre
        self.lista = lista
    }
}
