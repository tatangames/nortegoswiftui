//
//  SolvenciaCatastroViewModel.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 3/11/24.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class SolvenciaCatastroViewModel: ObservableObject {
    @Published var jsonResponse: JSON?
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    @Published var error: Error?
    
    private let disposeBag = DisposeBag()
     
    func solvenciaCatastroRX(idToken: String,
                            idCliente: String,
                            latitud: String,
                            longitud: String,
                            tipoSoli: Int,
                            nombre: String,
                            dui: String,
                            completion: @escaping (Result<JSON, Error>) -> Void) {
                        
        // Verificar si ya hay una solicitud en curso
        guard !isRequestInProgress else { return }
        
        // Indicar que la solicitud está en progreso
        isRequestInProgress = true
        loadingSpinner = true
        
        let encodeURL = apiEnviarDatosCatastro
        let headers: HTTPHeaders = ["Authorization": "Bearer \(idToken)"]
        let parameters: [String: Any] = [
            "id": idCliente,
            "latitud": latitud,
            "longitud": longitud,
            "tiposoli": tipoSoli,
            "nombre": nombre,
            "dui": dui
        ]
        
        Observable<JSON>.create { observer in
            let request = AF.request(encodeURL, method: .post, parameters: parameters, headers: headers)
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
                request.cancel()
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
