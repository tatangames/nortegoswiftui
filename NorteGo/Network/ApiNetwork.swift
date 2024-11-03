//
//  ApiNetwork.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 18/8/24.
//

import Foundation

let apiVersionApp = "v. 1.0.0"

// utilizado cuando hay un nuevo servicio
let apiURLAppleStore = "https://apps.apple.com/app/nortego/idxxxxxx"

let baseUrl = "http://145.223.120.223/api/"
let baseUrlImagen = "http://145.223.120.223/storage/archivos/"

let apiVerificarTelefono = baseUrl+"app/verificacion/telefono"
let apiReintentoSMS = baseUrl+"app/reintento/telefono"
let apiVerificarCodigo = baseUrl+"app/verificarcodigo/telefono"

let apiPrincipal = baseUrl+"app/principal/listado"
let apiListadoSolicitudes = baseUrl+"app/solicitudes/listado"
let apiSolicitudOcultar = baseUrl+"app/solicitudes/ocultar"
let apiEnviarDatosDenuncia = baseUrl+"app/servicios/basicos/registrar"
let apiEnviarDatosCatastro = baseUrl+"app/solicitud/catastro"
let apiEnviarDatosSolitudTalaArbol = baseUrl+"app/servicios/talaarbol-solicitud/registrar"
let apiEnviarDatosDenunciaTalaArbol = baseUrl+"app/servicios/talaarbol-denuncia/registrar"
