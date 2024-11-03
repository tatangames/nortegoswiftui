//
//  CodigoOtpViewModel.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 25/10/24.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class CodigoOtpViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func VerificarCodigoRX(telefono: String, codigo: String, idonesignal: String) -> Observable<Result<JSON, Error>> {
        
        // Si ya hay una solicitud en progreso, retorna un Observable vacío
        guard !isRequestInProgress else {
            return Observable.just(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
        }
        
        isRequestInProgress = true
        
        return Observable<Result<JSON, Error>>.create { observer in
            self.loadingSpinner = true
            let encodeURL = apiVerificarCodigo
            let parameters: [String: Any] = [
                "telefono": telefono,
                "codigo": codigo,
                "idonesignal": idonesignal
            ]
            
            let request = AF.request(encodeURL, method: .post, parameters: parameters)
                .responseData { response in
                    self.loadingSpinner = false
                    self.isRequestInProgress = false
                    
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        observer.onNext(.success(json))
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onNext(.failure(error))
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
