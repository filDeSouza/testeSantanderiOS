//
//  HomeViewController.swift
//  Teste Santander
//
//  Created by Filipe de Souza on 31/08/21.
//

import UIKit
import SDLoader


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Atributos
    var extratoModel: [ExtratoModel] = []
    var dadosUsuario: LoginModel!
    var utils = Utils()
    let sdLoader = SDLoader()

    // MARK: - IBOutlets
    @IBOutlet weak var labelNome: UILabel!
    @IBOutlet weak var labelDocumento: UILabel!
    @IBOutlet weak var labelSaldo: UILabel!
    @IBOutlet weak var tableViewExtrato: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        sdLoader.startAnimating(atView: self.view)
        
        self.labelNome.text = dadosUsuario.nome
        let cpfFormatado = dadosUsuario.cpf.toCPFNumber()
        self.labelDocumento.text = cpfFormatado

        let valorFormatado = utils.formatacaoMoeda(valor: dadosUsuario.saldo)
        self.labelSaldo.text = valorFormatado

        APIRest.dadosExtrato(token: dadosUsuario.token) { (extrato) in
            DispatchQueue.main.async {
                self.extratoModel = extrato
                self.tableViewExtrato.delegate = self
                self.tableViewExtrato.dataSource = self
                self.tableViewExtrato.reloadData()
                self.sdLoader.stopAnimation()

            }
        } onError: { (error) in
            switch error{
            case .invalidJSON:
                print("JSON inválido")
            case .noData:
                print("Sem dados")
            case .noResponse:
                print("JSON inválido")
            default:
                print("")
        }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let layer = CAGradientLayer()
        let startColor = UIColor(red: 204.0/255.0, green: 229.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        let finalColor = UIColor(red: 51.0/255.0, green: 153.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        layer.frame = self.headerView.frame
        layer.colors = [startColor, finalColor]
        layer.startPoint = CGPoint(x: 0.0, y: 1.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.headerView.layer.insertSublayer(layer, at: 0)

    }

    // MARK: - Functions TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extratoModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CelulaPersonalizadaExtrato
        let extratoCelula = extratoModel[indexPath.row]
        
        cell.cellView.layer.shadowColor = UIColor.black.cgColor
        cell.cellView.layer.shadowPath = UIBezierPath(rect: cell.cellView.layer.bounds).cgPath
        cell.cellView.layer.shadowRadius = 5
        cell.cellView.layer.shadowOffset = .zero
        cell.cellView.layer.shadowOpacity = 0.5

        if extratoCelula.valor < 0 {
            cell.lbTipo.text = "Pagamento"
            cell.lbValor.textColor = UIColor.red
        }else{
            cell.lbTipo.text = "Crédito"
            cell.lbValor.textColor = UIColor.green
        }
                        
        cell.lbData.text = utils.formatacaoData(data: extratoCelula.data)
        
        cell.lbDescricao.text = extratoCelula.descricao
        
        cell.lbValor.text = utils.formatacaoMoeda(valor: extratoCelula.valor)
                
        return cell
        
    }
    
    // MARK: - IBActions
    @IBAction func logout(_ sender: Any) {
        
        let alert = UIAlertController(title: "Aviso", message: "Deseja realmente sair de sua conta?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { action in
                    self.performSegue(withIdentifier: "segueLogout", sender: self)
                    self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        

        
    }
    
}

