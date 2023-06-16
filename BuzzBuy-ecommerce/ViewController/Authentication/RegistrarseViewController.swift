//
//  RegistrarseViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit

class RegistrarseViewController: UIViewController {

    // Textfields
    @IBOutlet weak var nombreRegistro: UITextField!
    @IBOutlet weak var apellidoRegistro: UITextField!
    
    @IBOutlet weak var emailRegistro: UITextField!
    @IBOutlet weak var passwordRegistro: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Botones para registar usuario
    @IBAction func RegistrarTapped(_ sender: Any) {
    }
    
    @IBAction func RegistrarGoogleTapped(_ sender: Any) {
    }
    
    @IBAction func RegistrarFacebookTapped(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
