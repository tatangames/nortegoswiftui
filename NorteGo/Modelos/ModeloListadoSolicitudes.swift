//
//  ModeloListadoSolicitudes.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 26/8/24.
//

import Foundation

class ModeloListadoSolicitudes: Identifiable{
    var id: Int
    var tipo: Int
    var nombretipo: String
    var estado: String
    var nota: String
    var fecha: String
    var nombre: String
    var telefono: String
    var direccion: String
    var escritura: Int
    var dui: String
    var imagen: String
    
    init(id: Int, tipo: Int, nombretipo: String, estado: String, nota: String, fecha: String, nombre: String, telefono: String, direccion: String, escritura: Int, dui: String, imagen: String) {
        self.id = id
        self.tipo = tipo
        self.nombretipo = nombretipo
        self.estado = estado
        self.nota = nota
        self.fecha = fecha
        self.nombre = nombre
        self.telefono = telefono
        self.direccion = direccion
        self.escritura = escritura
        self.dui = dui
        self.imagen = imagen
    }
}
