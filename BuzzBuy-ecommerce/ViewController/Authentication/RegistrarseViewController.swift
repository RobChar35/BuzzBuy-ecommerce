//
//  RegistrarseViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegistrarseViewController: UIViewController {

    // Textfields
    @IBOutlet weak var nombreRegistro: UITextField!
    @IBOutlet weak var apellidoRegistro: UITextField!
    
    
    @IBOutlet weak var passwordRegistro: UITextField!
    
    @IBOutlet weak var emailRegistro: UITextField!
    @IBOutlet weak var usernameRegistro: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Botones para registar usuario
    @IBAction func RegistrarTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailRegistro.text!, password: passwordRegistro.text!) {
            (user, error) in
            print("Creando usuario")
            
            if error != nil {
                print("Error al crear usuario: \(error)")
                
                let alert = UIAlertController(title: "Error de creacion", message: "Error al momento de crear un usuario", preferredStyle: .alert)
                                
                let btnCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: {(UIAlertAction) in })
                
                alert.addAction(btnCancelar)
                self.present(alert, animated: true, completion: nil)
            } else {
                 
                let datosUsuario = [
                    "username": self.usernameRegistro.text!,
                    "nombre": self.nombreRegistro.text!,
                    "apellido": self.apellidoRegistro.text!,
                    "email": user!.user.email
                ]
                
                Database.database().reference().child("usuarios").child(user!.user.uid).child("datos_personales").setValue(datosUsuario)
                
                let alert = UIAlertController(title: "Creacion de nuevo usuario", message: "El usuario \(self.usernameRegistro.text!) fue creado correctamente", preferredStyle: .alert)
                
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {
                    (UIAlertAction) in
                    self.performSegue(withIdentifier: "cuentaExistenteSegue", sender: nil)
                })
                
                alert.addAction(btnOK)
                self.present(alert, animated: true, completion: nil)
                print("El nuevo usuario fue creado exitosamente")
            }
        }
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
