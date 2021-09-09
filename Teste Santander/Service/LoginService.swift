//
//  LoginService.swift
//  Teste Santander
//
//  Created by Virtual Machine on 02/09/21.
//

import Foundation
import UIKit

protocol LoginServiceDelegate {
    
    func deuCerto(user: LoginModel)
    func deuErrado(erro: Error)
}

class LoginService{
    
    private let baseURL = "https://api.mobile.test.solutis.xyz"
    var delegate: LoginServiceDelegate?
    private let configuration: URLSessionConfiguration = {
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 5.0
        return config
    }()
    
    private var session: URLSession?
    
    
    func loginPost(usuario: String, senha: String){
        
        self.session = URLSession(configuration: configuration)
                
        let urlString = baseURL + "/login"
        
        //testando se há algum problema na URL base
        guard let url = URL(string: urlString)else{
            return
        }
        
        let parametros = ["username":usuario, "password":senha] as Dictionary<String, String>
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(parametros);

        //abrindo uma sessão
        let dataTask = self.session!.dataTask(with: request, completionHandler:  { data, response, error in
            
            if error != nil{
                self.delegate?.deuErrado(erro: error!)
                return
            }
            guard let response = response as? HTTPURLResponse else{
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
                        print("Valores da API: ", json)
                        usuario.nome = (json["nome"] as! String)
                        usuario.cpf = json["cpf"] as! String
                        usuario.token = json["token"] as! String
                        usuario.saldo = (json["saldo"] as! NSNumber).doubleValue
                    }
                    self.delegate?.deuCerto(user: usuario)
                    
                }catch{
                    self.delegate?.deuErrado(erro: error)
                    print(error.localizedDescription)
                }
            }
            
        })
        dataTask.resume()
        }
    
}
