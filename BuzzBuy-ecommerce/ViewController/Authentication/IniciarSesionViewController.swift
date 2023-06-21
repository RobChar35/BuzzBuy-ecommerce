//
//  IniciarSesionViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit

class IniciarSesionViewController: UIViewController {

    // Textfields
    @IBOutlet weak var emailIniciarSesion: UITextField!
    @IBOutlet weak var passwordIniciarSesion: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Botones para iniciar sesion
    @IBAction func IniciarSesionTapped(_ sender: Any) {
    }
    
    @IBAction func IniciarSesionGoogleTapped(_ sender: Any) {
    }
    
    @IBAction func IniciarSesionFacebookTapped(_ sender: Any) {
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
