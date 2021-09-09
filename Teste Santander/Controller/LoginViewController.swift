//
//  LoginViewController.swift
//  Teste Santander
//
//  Created by Filipe de Souza on 31/08/21.
//

import UIKit
import SDLoader
import KeychainSwift

class LoginViewController: UIViewController{
    
    // MARK: - Atributos
    var loginService = LoginService()
    var utils = Utils()
    var camposVazios: Bool!
    var validacaoEmail: Bool!
    var validacaoSenha: Bool!
    var validacaoCPF: Bool!
    let sdLoader = SDLoader()
    let keyChain = KeychainSwift()
    var dadosUsuario: LoginModel!
        
    // MARK: - IBOutlets
    @IBOutlet weak var tfUsuario: UITextField!
    @IBOutlet weak var tfsenha: UITextField!
    @IBOutlet weak var btLogin: UIButton!
    @IBOutlet weak var labelErro: UILabel!
    
    // MARK: - IBActions
    @IBAction func login(_ sender: UIButton){
        
        sdLoader.startAnimating(atView: self.view)
        
        camposVazios = utils.validarDadosVazios(dadosUsuario: self.tfUsuario.text!, dadosSenha: self.tfsenha.text!)
        validacaoEmail = utils.isEmailValido(self.tfUsuario.text!)
        validacaoSenha = utils.validacaoSenha(senha: self.tfsenha.text!)
        validacaoCPF = utils.validarCPF(self.tfUsuario.text!)
        if camposVazios {
            labelErro.isHidden = false
            labelErro.text = "Os campos User e Password devem ser preenchidos"
            sdLoader.stopAnimation()
        } else if !validacaoEmail && !validacaoCPF{
            labelErro.isHidden = false
            labelErro.text = "Login ou senha inválidos"
            sdLoader.stopAnimation()
        } else if !validacaoSenha{
            labelErro.isHidden = false
            labelErro.text = "Login ou senha inválidos"
            sdLoader.stopAnimation()
        } else{
            APIRest.loginPost(usuario: self.tfUsuario.text!, senha: self.tfsenha.text!, onComplete: {(usuario) in
                DispatchQueue.main.async {
                    
                    self.keyChain.set(self.tfUsuario.text!, forKey: "usuario")
                                        
                    self.dadosUsuario = usuario
                    self.performSegue(withIdentifier: "segueHome", sender: self)

                }

            }, onError: {(error) in
                switch error{
                case .invalidJSON:
                    print("JSON inválido")
                case .noData:
                    print("Sem dados")
                case .noResponse:
                    print("Sem resposta da API")
                case .erroResposta:
                    DispatchQueue.main.async {
                        self.erroLogin()
                    }
                default:
                    print("Erro genérico")
                }
            })
        }
                
    }
        
    @IBAction func sumirTeclado(_ sender: Any) {
        
        self.view.endEditing(true)
        
    }
        
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if keyChain.get("usuario") != nil {
            self.tfUsuario.text = keyChain.get("usuario")
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        labelErro.isHidden = true
        tfsenha.isSecureTextEntry = true
    }
    
    func erroLogin(){
        
        DispatchQueue.main.async {
            
            self.labelErro.isHidden = false
            self.labelErro.text = "Login ou senha inválidos"
            self.sdLoader.stopAnimation()

        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueHome"{
                let viewController = segue.destination as! HomeViewController
                viewController.dadosUsuario = self.dadosUsuario
                self.dismiss(animated: true, completion: nil)
                sdLoader.stopAnimation()

        }
    }
    
}
