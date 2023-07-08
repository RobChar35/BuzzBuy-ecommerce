//
//  RegistrarseViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseCore
import FirebaseAnalytics

import GoogleSignIn

class RegistrarseViewController: UIViewController {

    // Textfields
    @IBOutlet weak var nombreRegistro: UITextField!
    @IBOutlet weak var apellidoRegistro: UITextField!
    
    @IBOutlet weak var usernameRegistro: UITextField!
    @IBOutlet weak var emailRegistro: UITextField!
    @IBOutlet weak var passwordRegistro: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // Do any additional setup after loading the view.
    }
    
    // Botones para registar usuario
    @IBAction func RegistrarTapped(_ sender: Any) {
        Analytics.logEvent("registrar_sesion", parameters: nil)
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
                let name = self.nombreRegistro.text!
                let last_name = self.apellidoRegistro.text!
                let full_name = name + " " + last_name
                
                let datosUsuario = [
                    "username": self.usernameRegistro.text!,
                    "nombre": full_name,
                    "email": user!.user.email,
                    "fotoPerfil": ""
                ]
                
                Database.database().reference().child("usuarios").child(user!.user.uid).child("datos_personales").setValue(datosUsuario)
                
                let alert = UIAlertController(title: "Creacion de nuevo usuario", message: "El usuario \(self.usernameRegistro.text!) fue creado correctamente", preferredStyle: .alert)
                
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {
                    (UIAlertAction) in
                    self.performSegue(withIdentifier: "registroSuccessSegue", sender: nil)
                })
                
                alert.addAction(btnOK)
                self.present(alert, animated: true, completion: nil)
                print("El nuevo usuario fue creado exitosamente")
            }
        }
    }
    
    @IBAction func RegistrarGoogleTapped(_ sender: Any) {
        Analytics.logEvent("registrar_google_tapped", parameters: nil)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {[unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                print("Creando un nuevo usuario e iniciando sesion")
                if let error = error {
                    print("Se presento el siguiente error: \(error)")
                } else {
                    print("Usario creado exitosamente")
                    
                    let userGoogle = Auth.auth().currentUser
                    
                    if let user = userGoogle {
                        print("user", user)
                        
                        let email = userGoogle!.email
                        let name = userGoogle!.displayName
                        let fotoPerfil = userGoogle!.photoURL
                        
                        var datosUsuario = [
                            "username": name,
                            "nombre": name,
                            "email": email
                        ]
                        
                        if userGoogle!.photoURL == fotoPerfil {
                            let storageRef = Storage.storage().reference()
                            let usuariosDir = storageRef.child("usuarios")
                            
                            URLSession.shared.dataTask(with: userGoogle!.photoURL!) {
                                (data, response, error) in
                                guard let data = data, error == nil else {
                                    return
                                }
                                
                                let subirImagenGUser = usuariosDir.child("\(user.uid).jpg")
                                subirImagenGUser.putData(data, metadata: nil) { (metadata, error) in
                                    if let error = error {
                                        print("Error al subir la foto de perfil: \(error)")
                                    } else {
                                        print("La foto de perfil se subio correctamente")
                                        
                                        subirImagenGUser.downloadURL {
                                            (url ,error) in
                                            if let downloadURL = url {
                                                var photoURLString = downloadURL.absoluteString
                                                datosUsuario["fotoPerfil"] = photoURLString
                                                Database.database().reference().child("usuarios").child(user.uid).child("datos_personales").setValue(datosUsuario)
                                            }
                                        }
                                    }
                                }
                            }.resume()
                        }
                        
                        Database.database().reference().child("usuarios").child(user.uid).child("datos_personales").setValue(datosUsuario)
                    }
                    
                    self.performSegue(withIdentifier: "registroSuccessSegue", sender: nil)
                }
            }
            
            
        }
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
