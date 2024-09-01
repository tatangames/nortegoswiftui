//
//  ApiNetwork.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 18/8/24.
//

import Foundation

let apiVersionApp = "ios 1.0.0"
let apiURLAppleStore = "https://apps.apple.com/app/mi-caminar-con-dios/id6480132659"

let baseUrl:String = "http://192.168.1.29:8080/api/"
let baseUrlImagen: String = "http://192.168.1.29:8080/storage/archivos/"

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
