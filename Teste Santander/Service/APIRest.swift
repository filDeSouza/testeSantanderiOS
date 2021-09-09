//
//  APIRest.swift
//  Teste Santander
//
//  Created by Filipe de Souza on 31/08/21.
//

import Foundation
import UIKit

enum LoginError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
    case erroResposta
}

enum ExtratoError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}


class APIRest{
    
    private static let baseURL = "https://api.mobile.test.solutis.xyz"
    
    private static let configuration: URLSessionConfiguration = {
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 5.0
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)
    
    class func loginPost(usuario: String, senha: String, onComplete: @escaping (LoginModel) -> Void, onError: @escaping(LoginError) -> Void){
        
        let urlString = baseURL + "/login"
        
        //testando se há algum problema na URL base
        guard let url = URL(string: urlString)else{
            onError(.url)
            return
        }
        
        let parametros = ["username":usuario, "password":senha] as Dictionary<String, String>
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(parametros);

        //abrindo uma sessão
        let dataTask = session.dataTask(with: request, completionHandler:  { data, response, error in
            
            if error != nil{
                print("Erro de requisição")
                return
            }
            guard let response = response as? HTTPURLResponse else{
                onError(.noResponse)
                return
                
            }
            if response.statusCode == 200 {
                print(response)
                do{
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    
                    let usuario = LoginModel()
                    
                    if json["message"] != nil {
                        print("Erro na utilização dos dados")
                    }else{
                        usuario.nome = (json["nome"] as! String)
                        usuario.cpf = json["cpf"] as! String
                        usuario.token = json["token"] as! String
                        usuario.saldo = (json["saldo"] as! NSNumber).doubleValue
                    }
                    onComplete(usuario)
                    
                }catch{
                    print(error.localizedDescription)
                    onError(.invalidJSON)
                }
            }else if response.statusCode == 401{
                onError(.erroResposta)
            }
            
        })
        dataTask.resume()
        }
    
    class func dadosExtrato (token: String, onComplete: @escaping ([ExtratoModel]) -> Void, onError: @escaping(ExtratoError) -> Void){
        
        let urlString = baseURL + "/extrato"
        
        guard let url = URL(string: urlString)else{
            onError(.url)
            return
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "token")
        
        let dataTask = session.dataTask(with: request, completionHandler:   { data, response, error in
            
            if error == nil {
                
                guard let response  = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                
                if response.statusCode == 200 {
                    print(response)
                    guard let data = data else{return}
                    do {
                        
                        let extrato = try JSONDecoder().decode([ExtratoModel].self, from: data)
                        
                            onComplete(extrato)
                        
                    } catch {
                        print(error.localizedDescription)
                        onError(.invalidJSON)
                    }
                }else{
                    print("Erro no REST: ", error ?? "não tem nada no erro")
                }
                
            }
            
        })
        dataTask.resume()
    }
}
