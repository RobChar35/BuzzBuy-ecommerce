//
//  EditarPerfilViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 7/07/23.
//

import UIKit

import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

import GoogleSignIn

class EditarPerfilViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var nombreCompleto: UITextField!
    @IBOutlet weak var nombredeusuario: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var fotoPerfilEditar: UIImageView!
    
    var perfilUsuario: Usuario?
    
    var ref: DatabaseReference!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(perfilUsuario)
        // Do any additional setup after loading the view.
        
        // Configurar referencia a la base de datos
        ref = Database.database().reference()
        
        
    //            Mostrar informacion del usuario
        populateData()
        
        // Configurar el image picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func populateData() {

        if let usuario = self.perfilUsuario {
            nombreCompleto.text = usuario.nombre
            nombredeusuario.text = usuario.username
            email.text = usuario.email
            
            if (GIDSignIn.sharedInstance.currentUser != nil) {
                email.text = usuario.email
                email.isEnabled = false
            } else {
                email.text = usuario.email
                email.isEnabled = true
            }
            
            if let fotoPerfilURL = URL(string: perfilUsuario!.fotoPerfil) {
                fotoPerfilEditar.sd_setImage(with: fotoPerfilURL, completed: nil)
            }
        }
    }
    
    @IBAction func guardarCambiosTapped(_ sender: Any) {
        // Obtener los nuevos valores de los campos de texto
        guard let nuevoNombre = nombreCompleto.text,
              let nuevoUsername = nombredeusuario.text,
              let nuevoEmail = email.text else {
            return
        }
        
        // Actualizar los valores en Firebase Realtime Database
        if let currentUser = Auth.auth().currentUser {
            let usuarioRef = ref.child("usuarios").child(currentUser.uid).child("datos_personales")
            
            // Actualizar los valores individuales
            usuarioRef.updateChildValues(["nombre": nuevoNombre])
            usuarioRef.updateChildValues(["username": nuevoUsername])
            usuarioRef.updateChildValues(["email": nuevoEmail])
            
            // Subir la imagen seleccionada a Firebase Storage
            if let imagenSeleccionada = fotoPerfilEditar.image {
                guard let imageData = imagenSeleccionada.jpegData(compressionQuality: 0.8) else {
                    return
                }
                
                let storageRef = Storage.storage().reference().child("imagenes_perfil").child(currentUser.uid)
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Ocurrió un error al subir la imagen
                        print("Error al subir la imagen: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
                    // Obtener la URL de descarga de la imagen
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Ocurrió un error al obtener la URL de descarga de la imagen
                            print("Error al obtener la URL de descarga de la imagen: \(error?.localizedDescription ?? "")")
                            return
                        }
                        
                        // Guardar la URL de la imagen en Firebase Realtime Database
                        usuarioRef.updateChildValues(["fotoPerfil": downloadURL.absoluteString])
                        
                        // Mostrar un mensaje de éxito o cualquier otro feedback necesario
                        print("Los datos se han actualizado correctamente")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                // No se seleccionó ninguna imagen, continuar con la actualización de los datos sin imagen
                print("Los datos se han actualizado correctamente")
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func cambiarFotoPerfilTapped(_ sender: Any) {
        //present(imagePicker, animated: true, completion: nil)
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imagenSeleccionada = info[.originalImage] as? UIImage else {
            return
        }
        
        // Aquí puedes realizar cualquier edición de la imagen seleccionada
        
        // Una vez que hayas terminado de editar, puedes utilizar la imagen resultante en tu vista
        // asignándola a tu elemento de imagen existente o creando uno nuevo
        
        // Por ejemplo, si tienes una UIImageView llamada "imagenView":
        fotoPerfilEditar.image = imagenSeleccionada
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelarCambiosTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
