//
//  ApiNetwork.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 18/8/24.
//

import Foundation

let apiVersionApp = "ios 1.0.0"

let baseUrl:String = "http://192.168.1.29:8080/api/"
let baseUrlImagen: String = "http://192.168.1.29:8080/storage/archivos/"

let apiVerificarTelefono = baseUrl+"app/verificacion/telefono"
let apiReintentoSMS = baseUrl+"app/reintento/telefono"
let apiVerificarCodigo = baseUrl+"app/verificarcodigo/telefono"

let apiPrincipal = baseUrl+"app/principal/listado"



