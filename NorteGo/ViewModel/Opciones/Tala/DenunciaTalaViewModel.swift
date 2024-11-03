//
//  DenunciaTalaViewModel.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 3/11/24.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class DenunciaTalaViewModel: ObservableObject {
    @Published var jsonResponse: JSON?
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    @Published var error: Error?
    
    private let disposeBag = DisposeBag()
     
    func enviarDenunciaTalaRX(idToken: String,
                            idCliente: String,
                            nota: String,
                            latitud: String,
                            longitud: String,
                            selectedImage: UIImage?, // Añadir la imagen como parámetro
                            completion: @escaping (Result<JSON, Error>) -> Void) {
        
        // Verificar si ya hay una solicitud en curso
        guard !isRequestInProgress else { return }
        
        // Indicar que la solicitud está en progreso
        isRequestInProgress = true
        loadingSpinner = true
        
        let encodeURL = apiEnviarDatosDenunciaTalaArbol
        let headers: HTTPHeaders = ["Authorization": "Bearer \(idToken)"]
        let parameters: [String: Any] = [
            "iduser": idCliente,
            "nota": nota,
            "latitud": latitud,
            "longitud": longitud
        ]
        
        // Crea un Observable para manejar la solicitud
        Observable<JSON>.create { observer in
            AF.upload(multipartFormData: { multipartFormData in
                // Añadir la imagen si está disponible
                if let imageData = selectedImage?.jpegData(compressionQuality: 0.5) {
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                }
                
                // Añadir otros parámetros
                for (key, value) in parameters {
                    if let data = "\(value)".data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }, to: encodeURL, method: .post, headers: headers)
            .validate() // Opcional: validar la respuesta
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    if let httpResponse = response.response, httpResponse.statusCode != 200 {
                        observer.onError(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error en el servidor con código: \(httpResponse.statusCode)"]))
                    } else {
                        observer.onNext(json)
                        observer.onCompleted()
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                // Cancelar la solicitud si es necesario
                AF.cancelAllRequests()
            }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                print("Error: \(error). Reintentando...")
                return Observable.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { json in
                self.jsonResponse = json
                self.loadingSpinner = false
                self.isRequestInProgress = false // La solicitud ha finalizado
                completion(.success(json))
            },
            onError: { error in
                self.error = error
                self.loadingSpinner = false
                self.isRequestInProgress = false // La solicitud ha finalizado con error
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}





