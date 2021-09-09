//
//  Utils.swift
//  Teste Santander
//
//  Created by Virtual Machine on 03/09/21.
//

import Foundation
import CPF_CNPJ_Validator

class Utils{
    
    func validarDadosVazios(dadosUsuario: String, dadosSenha: String) -> Bool{
        
        if dadosUsuario == "" || dadosSenha == "" {
            return true
        }else{
            return false
        }
        
    }
    
    func validarCPF(_ usuario: String) -> Bool{
        let cpf = BooleanValidator().validate(usuario, kind: .CPF)
        return cpf
    }
    
    func isEmailValido(_ email: String) -> Bool{
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
        
    }
    
    
    
    func validacaoSenha(senha: String) -> Bool{
        
        let passwordRegx = "^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegx).evaluate(with: senha)
        
    }

    
    func formatacaoMoeda(valor: Double) -> String{
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        let valorFormatado: String = currencyFormatter.string(from: NSNumber(value: valor))!
        return valorFormatado
        
    }
    
    func formatacaoData(data: String) -> String{
        
        let dataCompleta = (data.index(data.startIndex, offsetBy: 10))
        let data = (data.prefix(upTo: dataCompleta))
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        let date: Date = dateFormatterGet.date(from: String(data))!
        return dateFormatterPrint.string(from: date)
        
    }
        
}

extension String{
    public func toCPFNumber() -> String{
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d{3})(\\d{2})", with: "$1.$2.$3-$4", options: .regularExpression, range: nil)
    }
}

extension String{
    public func toCNPJNumber() -> String{
        return self.replacingOccurrences(of: "(\\d{2})(\\d{3})(\\d{3})(\\d{4})(\\d{2})", with: "$1.$2.$3/$4-$5", options: .regularExpression, range: nil)
    }
}


