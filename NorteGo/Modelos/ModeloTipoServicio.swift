//
//  ModeloTipoServicio.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 25/8/24.
//

import Foundation

class ModeloTipoServicio{
    
    var id: Int
    var id_cateservicio: Int
    var tiposervicio: Int
    var nombre: String
    var imagen: String
    
    init(id: Int, id_cateservicio: Int, tiposervicio: Int, nombre: String, imagen: String) {
        self.id = id
        self.id_cateservicio = id_cateservicio
        self.tiposervicio = tiposervicio
        self.nombre = nombre
        self.imagen = imagen
    }
}
