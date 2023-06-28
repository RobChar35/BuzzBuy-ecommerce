//
//  IniciarSesionViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit
import FirebaseAuth

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
        Auth.auth().signIn(withEmail: emailIniciarSesion.text!, password: passwordIniciarSesion.text!) {
            (user, error) in
            print("Intentando iniciar sesion")
            
            if error != nil {
                print("Error al iniciar sesion: \(error)")
                
                let alert = UIAlertController(title: "Error al iniciar sesion", message: "Se ingresaron datos incorrectos o el usuario no existe", preferredStyle: .alert)

                let btnCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: {(UIAlertAction) in })

                alert.addAction(btnCancelar)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Inicio de sesion exitoso")
                self.performSegue(withIdentifier: "iniciarSesionSegue", sender: nil)
            }
        }
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
