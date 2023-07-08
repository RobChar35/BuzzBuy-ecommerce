//
//  PerfilUsuarioViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 7/07/23.
//

import UIKit

import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import FirebaseAnalytics

class PerfilUsuarioViewController: UIViewController {
    
    @IBOutlet weak var nombreCompletoTextField: UILabel!
    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var fotoPerfil: UIImageView!
    
    var usuario: Usuario?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let currentUser = Auth.auth().currentUser
        // Listar datos basicos de usuarios
        Database.database().reference().child("usuarios").child((currentUser?.uid)!).child("datos_personales").observe(DataEventType.value, with: {(snapshot) in
            print("snapshot ==>", snapshot)
            
            if let userData = snapshot.value as? [String: Any] {
                print("USERDATA ==>>>>>>>", userData)
                
                let nombre = userData["nombre"] as? String ?? ""
                let username = userData["username"] as? String ?? ""
                let email = userData["email"] as? String ?? ""
                let fotoPerfil = userData["fotoPerfil"] as? String ?? ""
               
                self.usuario = Usuario()

                self.usuario?.nombre = nombre
                self.usuario?.username = username
                self.usuario?.email = email
                self.usuario?.fotoPerfil = fotoPerfil
                print(self.usuario)
            }

            self.nombreCompletoTextField.text = (snapshot.value as! NSDictionary)["nombre"] as? String
            self.usernameTextField.text = (snapshot.value as! NSDictionary)["username"] as? String
                        
            if let fotoPerfilURLString = (snapshot.value as! NSDictionary)["fotoPerfil"] as? String {
                if let fotoPerfilURL = URL(string: fotoPerfilURLString) {
                    self.fotoPerfil.sd_setImage(with: fotoPerfilURL, completed: nil)
                }
            }
        })
    }
    
    @IBAction func cerrarSesionTapped(_ sender: Any) {
        Analytics.logEvent("cerrar_sesion", parameters: nil)
        print("Cerrando sesion")
        
        let firebaseAuth = Auth.auth()
        do {
            print("La sesion fue cerrada exitosamente")
            
            try firebaseAuth.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error al cerrar sesion: \(signOutError)")
        }
    }
    
    @IBAction func editarPerfilTapped(_ sender: Any) {
        performSegue(withIdentifier: "editarPerfilSegue", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editarPerfilSegue" {
            if let editarPerfilVC = segue.destination as? EditarPerfilViewController {
                print("USUARIO =>>>>>>>", usuario)
                editarPerfilVC.perfilUsuario = self.usuario
            }
        }
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
