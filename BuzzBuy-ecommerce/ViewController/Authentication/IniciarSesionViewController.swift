//
//  IniciarSesionViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn

class IniciarSesionViewController: UIViewController {

    // Textfields
    @IBOutlet weak var emailIniciarSesion: UITextField!
    @IBOutlet weak var passwordIniciarSesion: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
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
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                print("Creando un nuevo usuario e iniciando sesion")
                if let error = error {
                    print("Se presento el siguiente error: \(error)")
                } else {
                    print("Inicio de sesion exitoso")
                    self.performSegue(withIdentifier: "iniciarSesionSegue", sender: nil)
                }
            }
        }
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
