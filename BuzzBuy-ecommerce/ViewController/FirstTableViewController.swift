//
//  FirstTableViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Mac 04 on 21/06/23.
//

import UIKit
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebaseAuth

class FirstTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var productos: [Producto] = []
    var userID:String = ""
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productos.count
    }
    
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
    
    var ref: DatabaseReference!

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productoCell", for: indexPath) // Cambia "productoCell" con el identificador de tu celda personalizada
        let producto = productos[indexPath.row]
        cell.textLabel?.text = producto.nombre
        cell.detailTextLabel?.text = producto.descripcion
        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        productsTable.delegate = self
        productsTable.dataSource = self
        productsTable.setEditing(true, animated: false)
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
        ref.child("productos").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observe(.value) { [weak self] (snapshot) in
                    guard let self = self else { return }
                    
                    // Borra los productos existentes antes de agregar los nuevos
                    self.productos.removeAll()
                    
                    // Recorre los datos obtenidos del snapshot
                    for childSnapshot in snapshot.children {
                        if let childSnapshot = childSnapshot as? DataSnapshot,
                           let productoData = childSnapshot.value as? [String: Any] {
                            // Crea un objeto Producto y agrega los datos a la lista
                            let producto = Producto()
                            producto.id = childSnapshot.key
                            producto.nombre = productoData["nombre"] as? String ?? ""
                            producto.descripcion = productoData["descripcion"] as? String ?? ""
                            producto.cantidad = productoData["cantidad"] as? String ?? ""
                            producto.precio = productoData["precio"] as? String ?? ""
                            producto.imagenURL = productoData["imagenURL"] as? String ?? ""
                            producto.categoria = productoData["categoria"] as? String ?? ""
                            self.productos.append(producto)
                        }
                    }
                    
                    // Actualiza la tabla con los nuevos datos
                    self.productsTable.reloadData()
                }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let producto = productos[indexPath.row]
        performSegue(withIdentifier: "EditarProductoSegue", sender: producto)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditarProductoSegue",
            let agregarProductoVC = segue.destination as? AgregarProductoViewController,
            let producto = sender as? Producto {
                agregarProductoVC.productoEditado = producto
                agregarProductoVC.productoID = producto.id
                agregarProductoVC.categoriapreseleccionada = producto.categoria
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let producto = productos[indexPath.row]
            
            // Obtener la URL de la imagen del producto
            let imagenURL = producto.imagenURL
            
            // Eliminar la imagen correspondiente en Firebase Storage
            let storageRef = Storage.storage().reference(forURL: imagenURL)
            storageRef.delete { (error) in
                if let error = error {
                    print("Error al eliminar la imagen: \(error.localizedDescription)")
                } else {
                    print("Imagen eliminada correctamente")
                    
                    // Eliminar el producto de la base de datos
                    self.ref.child("productos").child(producto.id).removeValue { (error, ref) in
                        if let error = error {
                            print("Error al eliminar el producto: \(error.localizedDescription)")
                        } else {
                            print("Producto eliminado correctamente")
                            let alert = UIAlertController(title: "Éxito", message: "Registro e imagen eliminados correctamente", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }


    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    @IBOutlet weak var productsTable: UITableView!
    
    @IBOutlet weak var btnEditar: UIButton!
    @IBAction func editar(_ sender: Any) {
        if btnEditar.titleLabel?.text == "Editar"{
            productsTable.setEditing(false, animated: false)
            btnEditar.setTitle("Eliminar", for: .normal)
        }else{
            productsTable.setEditing(true, animated: false)
            btnEditar.setTitle("Editar", for: .normal)
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
