//
//  PreCompraViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Mac 04 on 5/07/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class PreCompraViewController: UIViewController {
    var producto: Producto!
    var vendedorr: String = ""
    var vendedorID: String = ""
    var userLoggedId: String = ""
    var productoID: String = ""
    var cantidadd: String = ""
    override func viewDidLoad() {
            super.viewDidLoad()
            if let currentUser = Auth.auth().currentUser {
                // Obtener el ID del usuario logueado
                let userLogged = currentUser.uid
                print("ID del usuario logueado: \(userLogged)")
                self.userLoggedId = userLogged
                // Guardar el ID del usuario en una variable o realizar cualquier otra acción con él
            } else {
                // No se ha encontrado ningún usuario logueado
                print("No se ha encontrado ningún usuario logueado")
            }
            // Verificar si producto no es nil antes de acceder a sus propiedades
            if let producto = producto {
                // Asignar los datos del producto a las etiquetas y la imagen
                nombre.text = producto.nombre
                descripcion.text = producto.descripcion
                cantidad.text = producto.cantidad
                precio.text = "S/. " + producto.precio
                categoria.text = producto.categoria
                self.cantidadd = producto.cantidad
                
                // Realizar la búsqueda en la base de datos en tiempo real
                let databaseRef = Database.database().reference()
                let productosRef = databaseRef.child("productos")
                let productoRef = productosRef.child(producto.id)
                self.productoID = producto.id
                productoRef.observeSingleEvent(of: .value) { (snapshot) in
                    if let productoData = snapshot.value as? [String: Any],
                       let userID = productoData["userID"] as? String {
                        print("userID: " + userID)
                    }
                }
                productoRef.observeSingleEvent(of: .value) { (snapshot) in
                    if let productoData = snapshot.value as? [String: Any],
                       let userID = productoData["userID"] as? String {
                        print("userID: " + userID)
                        self.vendedorID = userID
                        let usuariosRef = databaseRef.child("usuarios").child(userID).child("datos_personales")
                        
                        usuariosRef.observeSingleEvent(of: .value) { (snapshot) in
                            if let usuarioData = snapshot.value as? [String: Any],
                               let nombre = usuarioData["nombre"] as? String {
                                print("Nombre del usuario: " + nombre)
                                self.vendedorr = nombre
                                self.vendedor.text = self.vendedorr
                            } else {
                                print("No se encontró el nombre del usuario")
                            }
                        }
                    } else {
                        print("No se encontró el userID en el producto")
                    }
                }


                // Cargar la imagen desde la URL si no es nil
                if let imageURL = URL(string: producto.imagenURL) {
                    URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                        if let data = data {
                            DispatchQueue.main.async {
                                self.imagen.image = UIImage(data: data)
                            }
                        }
                    }.resume()
                }
            } else {
                // Manejar el caso cuando producto es nil
                // Por ejemplo, mostrar un mensaje de error o realizar otra acción apropiada
            }
        }

    

    @IBOutlet weak var nombre: UILabel!
    
    @IBOutlet weak var descripcion: UILabel!
    
    @IBOutlet weak var cantidad: UILabel!
    
    @IBOutlet weak var precio: UILabel!
    
    @IBOutlet weak var categoria: UILabel!
    
    @IBOutlet weak var imagen: UIImageView!
    
    @IBAction func comprar(_ sender: Any) {
        if vendedorID == userLoggedId {
            let alertController = UIAlertController(title: "Alerta", message: "Usted no puede comprar su propio producto", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
        }else{
            if cantidadd == "0"{
                let alertController = UIAlertController(title: "Alerta", message: "Este producto ya no se encuentra disponible", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        present(alertController, animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "Alerta", message: "¿Esta seguro de comprar este producto?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Confirmar", style: .default) { (_) in
                    print("Compra confirmada")
                    
                    // Crear un nuevo nodo "compras" en la base de datos
                    let databaseRef = Database.database().reference()
                    let comprasRef = databaseRef.child("compras")
                    let nuevaCompraRef = comprasRef.childByAutoId()
                    
                    // Guardar los valores en los campos correspondientes
                    nuevaCompraRef.child("vendedor").setValue(self.vendedorID)
                    nuevaCompraRef.child("comprador").setValue(self.userLoggedId)
                    nuevaCompraRef.child("producto").setValue(self.productoID)
                    
                    // Obtener la referencia al producto
                    let productosRef = databaseRef.child("productos")
                    let productoRef = productosRef.child(self.productoID)
                    
                    // Obtener el valor actual de "cantidad" del producto
                    productoRef.child("cantidad").observeSingleEvent(of: .value) { (snapshot) in
                        if let cantidadString = snapshot.value as? String,
                           var cantidad = Int(cantidadString) {
                            // Restar 1 a la cantidad
                            cantidad -= 1
                            
                            // Actualizar el campo "cantidad" en la base de datos
                            productoRef.child("cantidad").setValue(String(cantidad))
                            
                            // Mostrar una alerta de compra confirmada
                            let compraConfirmadaAlertController = UIAlertController(title: "Compra Confirmada", message: "¡Su compra ha sido realizada con éxito!", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            compraConfirmadaAlertController.addAction(okAction)
                            self.present(compraConfirmadaAlertController, animated: true, completion: nil)
                        }
                    }
                    
                    // Aquí puedes agregar tu lógica adicional después de guardar los datos de la compra
                }

                        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        alertController.addAction(cancelAction)
                        present(alertController, animated: true, completion: nil)
            }
            }
        }
    
    @IBOutlet weak var vendedor: UILabel!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
