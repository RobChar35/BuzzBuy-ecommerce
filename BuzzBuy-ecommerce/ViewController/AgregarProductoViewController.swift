//
//  AgregarProductoViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Mac 04 on 21/06/23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import FirebaseAuth
import FirebaseAnalytics

class AgregarProductoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categorias.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return categorias[row]
        }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            categoriaseleccionada = categorias[row] // Guardar la selección del usuario en la variable categoriaseleccionada
        }

    var categoriapreseleccionada:String = ""
    var categoriaseleccionada:String = ""
    let categorias: [String] = ["Cocina", "Tecnología", "Herramientas", "Juegos", "Mecanica"]
    var ref: DatabaseReference!
    var imagenurl: String = ""
    var imagenID = NSUUID().uuidString
    var imagePicker = UIImagePickerController()
    var userID:String = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Verificar si hay un usuario logueado
        if Auth.auth().currentUser == nil {
            // No hay un usuario logueado, redirigir a la página de inicio de sesión o a la vista principal de autenticación
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = loginViewController
                window.makeKeyAndVisible()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imagen.image = image
            imagen.backgroundColor = UIColor.clear
            imagePicker.dismiss(animated: true, completion: nil)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        selectCategoria.dataSource = self
        selectCategoria.delegate = self
        ref = Database.database().reference()
        
        if let currentUser = Auth.auth().currentUser {
                    // El usuario está logueado
                    userID = currentUser.uid // Obtener el ID del usuario

                    // Realizar la búsqueda en Realtime Database utilizando el ID del usuario
                    let databaseRef = Database.database().reference().child("usuarios").child(userID).child("datos_personales")
                    databaseRef.observeSingleEvent(of: .value) { snapshot in
                        if let userData = snapshot.value as? [String: Any],
                           let name = userData["nombre"] as? String {
                            // Obtener el nombre del usuario
                            print("Nombre del usuario:", name)
                        } else {
                            print("No se encontró información del usuario en Realtime Database")
                        }
                    }
        }
        
        if let producto = productoEditado {
                    // Rellenar los campos con los datos del producto existente
                    botonagregar.setTitle("Editar", for: .normal)
                    txtNombre.text = producto.nombre
                    txtDescripcion.text = producto.descripcion
                    txtCantidad.text = producto.cantidad
                    txtPrecio.text = producto.precio
                    imagen.sd_setImage(with: URL(string: producto.imagenURL), completed: nil)
                }
        selectCategoria.reloadAllComponents()
        if let selectedIndex = categorias.firstIndex(of: categoriapreseleccionada) {
                    selectCategoria.selectRow(selectedIndex, inComponent: 0, animated: false)
                }
        
        
    }
    
    @IBOutlet weak var txtNombre: UITextField!
    
    @IBOutlet weak var txtDescripcion: UITextField!
    
    @IBOutlet weak var txtCantidad: UITextField!
    
    @IBOutlet weak var txtPrecio: UITextField!
    
    var productoEditado: Producto?
    var productoID: String?
    @IBOutlet weak var botonagregar: UIButton!
    
    @IBOutlet weak var imagen: UIImageView!
    @IBAction func agregarImagen(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func agregar(_ sender: Any) {
        
        let imagenesFolder = Storage.storage().reference().child("images")
        let imagenData = imagen.image?.jpegData(compressionQuality: 0.50)
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
       
        let dispatchGroup = DispatchGroup()

        if let producto = productoEditado {
            let imagenAnteriorRef = Storage.storage().reference(forURL: producto.imagenURL)
            
            // Eliminar la imagen anterior
            dispatchGroup.enter()
            imagenAnteriorRef.delete { error in
                if let error = error {
                    print("Error al eliminar la imagen anterior: \(error.localizedDescription)")
                } else {
                    
                    cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Ocurrió un error al subir imagen: \(error)")
                        } else {
                            dispatchGroup.enter()
                            cargarImagen.downloadURL { (url, error) in
                                defer {
                                    dispatchGroup.leave()
                                }
                                
                                if let error = error {
                                    print("Ocurrió un error al obtener la url de la imagen: \(error)")
                                } else if let url = url {
                                    self.imagenurl = url.absoluteString
                                    print("URL de la imagen subida: \(self.imagenurl)")
                                }
                            }
                        }
                        
                        dispatchGroup.leave()
                    }
                }
            }
        } else {
            dispatchGroup.enter()
            cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Ocurrió un error al subir imagen: \(error)")
                } else {
                    dispatchGroup.enter()
                    cargarImagen.downloadURL { (url, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        if let error = error {
                            print("Ocurrió un error al obtener la url de la imagen: \(error)")
                        } else if let url = url {
                            self.imagenurl = url.absoluteString
                            print("URL de la imagen subida: \(self.imagenurl)")
                        }
                    }
                }
                
                dispatchGroup.leave()
            }
        }


        dispatchGroup.notify(queue: .main){ [self] in
                    print("Imagen subida o actualizada satisfactoriamente")
            guard let nombre = self.txtNombre.text,
                  let descripcion = self.txtDescripcion.text,
                  let cantidad = self.txtCantidad.text,
                  let precio = self.txtPrecio.text else {
                              return
                          }
                    
                    // Crea un diccionario con los datos del producto
                    let productoData: [String: Any] = [
                        "nombre": nombre,
                        "descripcion": descripcion,
                        "cantidad": cantidad,
                        "precio": precio,
                        "imagenURL": self.imagenurl,
                        "categoria": self.categoriaseleccionada,
                        "userID": self.userID
                    ]
                    
            if let producto = self.productoEditado {
                var productoDataWithID = productoData
                productoDataWithID["id"] = self.productoID
                productoDataWithID["imagenURL"] = self.imagenurl
                // Actualizar el producto existente
                self.ref.child("productos").child(producto.id).updateChildValues(productoDataWithID) { (error, ref) in
                    if let error = error {
                        print("Error al editar el producto: \(error.localizedDescription)")
                    } else {
                        Analytics.logEvent("editar_producto", parameters: nil)
                        print("Producto editado correctamente")
                        let alert = UIAlertController(title: "Éxito", message: "Registro actualizado satisfactoriamente", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                // Insertar los datos del producto en la base de datos
                let productoRef = self.ref.child("productos").childByAutoId() // Genera una referencia al nuevo producto
                let productoID = productoRef.key! // Obtiene el ID del nuevo producto
                
                // Agrega el ID al diccionario de datos del producto
                var productoDataWithID = productoData
                productoDataWithID["id"] = productoID
                productoDataWithID["imagenURL"] = self.imagenurl
                // Inserta los datos del producto en la base de datos
                productoRef.setValue(productoDataWithID) { (error, ref) in
                    if let error = error {
                        print("Error al agregar el producto: \(error.localizedDescription)")
                    } else {
                        Analytics.logEvent("agregar_producto", parameters: nil)
                        print("Producto agregado correctamente")
                        let alert = UIAlertController(title: "Éxito", message: "Registro agregado correctamente", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
                }
        
        
        





    }
    
    @IBOutlet weak var selectCategoria: UIPickerView!
    

    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
