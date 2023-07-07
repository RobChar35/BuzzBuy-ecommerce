//
//  InventarioViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

/*class CustomCell: UITableViewCell {
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblDescripcion: UILabel!
    @IBOutlet weak var lblPrecio: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    func configureCell(nombre: String, descripcion: String, precio: String, imagenurl: String) {
        lblNombre.text = nombre
        lblDescripcion.text = descripcion
        lblPrecio.text = precio
        imgView.sd_setImage(with: URL(string: imagenurl))
    }


}*/
    
class InventarioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableInventario: UITableView!
    var imagenurl: String = ""
    @IBOutlet weak var selectFilter: UISegmentedControl!
    var productos:[Producto] = []
    var ref: DatabaseReference!
    let categorias: [String] = ["Cocina", "Tecnología", "Herramientas", "Juegos", "Mecanica"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let producto = productos[indexPath.row]
        performSegue(withIdentifier: "detallessegue", sender: producto)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detallessegue" {
            if let indexPath = tableInventario.indexPathForSelectedRow {
                let producto = productos[indexPath.row]
                let sanitizedID = producto.id.replacingOccurrences(of: ".", with: "_")
                producto.id = sanitizedID  // Modificar el ID del producto
                
                let destinationVC = segue.destination as! PreCompraViewController
                destinationVC.producto = producto
            }
        }
    }



    
    /*override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            // Inicializa la propiedad imageni antes de llamar a super.init()
            self.imageni = UIImageView()
            
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            // Resto de la inicialización
        }
        
        required init?(coder aDecoder: NSCoder) {
            // Inicializa la propiedad imageni antes de llamar a super.init(coder:)
            self.imageni = UIImageView()
            
            super.init(coder: aDecoder)
            // Resto de la inicialización
        }*/


    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomProductCell", for: indexPath) as! CustomProductCell

            let producto = productos[indexPath.row]

            // Configure other cell properties like name, description, and price
            cell.nameLabel.text = producto.nombre
            cell.descriptionLabel.text = producto.descripcion
            cell.priceLabel.text = "\(producto.precio)"

            let imageURLString = producto.imagenURL
            let imageURL = URL(string: imageURLString)
            cell.imageView!.sd_setImage(with: URL(string: producto.imagenURL), completed: nil)
            //imagen.sd_setImage(with: URL(string: producto.imagenURL), completed: nil)

            return cell
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableInventario.register(CustomProductCell.self, forCellReuseIdentifier: "CustomProductCell")
        tableInventario.dataSource = self
        tableInventario.delegate = self
        ref = Database.database().reference()
        selectFilter.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        observarProductos()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observarProductos()
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0:
                // Lógica para mostrar todos los datos
                observarProductos()
            case 1:
                showCategoriasActionSheet()
            case 2:
                showPrecioActionSheet()
            default:
                break
            }
        }
    
    func showCategoriasActionSheet() {
        let alertController = UIAlertController(title: "Seleccionar Categoría", message: nil, preferredStyle: .actionSheet)
        
        for categoria in categorias {
            let action = UIAlertAction(title: categoria, style: .default) { [weak self] (_) in
                self?.filtrarProductosPorCategoria(categoria)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func filtrarProductosPorCategoria(_ categoria: String) {
        ref = Database.database().reference()
        ref.child("productos").queryOrdered(byChild: "categoria").queryEqual(toValue: categoria).observe(.value) { [weak self] (snapshot) in
            guard let self = self else { return }
            
            // Borra los productos existentes antes de agregar los nuevos
            self.productos.removeAll()
            
            // Recorre los datos obtenidos del snapshot
            self.productos = snapshot.children.compactMap { childSnapshot in
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
                    return producto
                }
                
                return nil
            }
            
            // Actualiza la tabla con los nuevos datos
            self.tableInventario.reloadData()
            print("Productos filtrados: \(self.productos)")
        }
    }



    
    func observarProductos() {
            ref.child("productos").observe(.value) { [weak self] (snapshot) in
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
                        print("Producto: \(producto.nombre)")
                    }
                    
                }
                
                // Actualiza la tabla con los nuevos datos
                self.tableInventario.reloadData()
            }
            
        }
    
    func showPrecioActionSheet() {
        let alertController = UIAlertController(title: "Seleccionar Precio", message: nil, preferredStyle: .actionSheet)
        
        let menos10Action = UIAlertAction(title: "Menos de S/ 10", style: .default) { [weak self] (_) in
            self?.filtrarProductosPorPrecio("0", "10")
        }
        alertController.addAction(menos10Action)
        
        let entre10y50Action = UIAlertAction(title: "Entre S/ 10 y S/ 50", style: .default) { [weak self] (_) in
            self?.filtrarProductosPorPrecio("10", "50")
        }
        alertController.addAction(entre10y50Action)
        
        let mas50Action = UIAlertAction(title: "Más de S/ 50", style: .default) { [weak self] (_) in
            self?.filtrarProductosPorPrecio("50", nil)
        }
        alertController.addAction(mas50Action)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func filtrarProductosPorPrecio(_ precioMinimo: String, _ precioMaximo: String?) {
        ref = Database.database().reference()
        ref.child("productos").observe(.value) { [weak self] (snapshot) in
            guard let self = self else { return }
            
            // Borra los productos existentes antes de agregar los nuevos
            self.productos.removeAll()
            
            // Recorre los datos obtenidos del snapshot
            for childSnapshot in snapshot.children {
                if let childSnapshot = childSnapshot as? DataSnapshot,
                   let productoData = childSnapshot.value as? [String: Any] {
                    // Obtener el precio del producto
                    let precioString = productoData["precio"] as? String ?? ""
                    
                    // Convertir el precio a un número
                    if let precio = Double(precioString),
                       let precioMin = Double(precioMinimo),
                       (precioMaximo == nil || precio <= Double(precioMaximo!)!) {
                        // Verificar si el precio está dentro del rango
                        if precio >= precioMin {
                            // Crea un objeto Producto y agrega los datos a la lista
                            let producto = Producto()
                            producto.id = childSnapshot.key
                            producto.nombre = productoData["nombre"] as? String ?? ""
                            producto.descripcion = productoData["descripcion"] as? String ?? ""
                            producto.cantidad = productoData["cantidad"] as? String ?? ""
                            producto.precio = precioString
                            producto.imagenURL = productoData["imagenURL"] as? String ?? ""
                            producto.categoria = productoData["categoria"] as? String ?? ""
                            self.productos.append(producto)
                        }
                    }
                }
            }
            
            // Actualiza la tabla con los nuevos datos
            self.tableInventario.reloadData()
            print("Productos filtrados: \(self.productos)")
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

class CustomProductCell: UITableViewCell {
    // Propiedades de la celda
    var nameLabel: UILabel!
    var descriptionLabel: UILabel!
    var priceLabel: UILabel!
    var productImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Configurar la apariencia de la celda
        configureCellAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCellAppearance() {
        // Configurar las subvistas de la celda
        nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 14.0)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 14.0)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)

        productImageView = UIImageView()
        productImageView.contentMode = .scaleAspectFit
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productImageView)

        // Configurar las restricciones de diseño de la celda
        let views: [String: Any] = [
            "nameLabel": nameLabel,
            "descriptionLabel": descriptionLabel,
            "priceLabel": priceLabel,
            "productImageView": productImageView
        ]

        let imageWidth: CGFloat = 20.0
        let imageHeight: CGFloat = 40.0

        contentView.addConstraints([
            NSLayoutConstraint(item: productImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: productImageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: productImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: imageWidth),
            NSLayoutConstraint(item: productImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: imageHeight),

            NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: productImageView, attribute: .bottom, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: nameLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: -16.0),

            NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: nameLabel, attribute: .bottom, multiplier: 1.0, constant: 4.0),
            NSLayoutConstraint(item: descriptionLabel, attribute: .leading, relatedBy: .equal, toItem: nameLabel, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: descriptionLabel, attribute: .trailing, relatedBy: .equal, toItem: nameLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0),

            NSLayoutConstraint(item: priceLabel, attribute: .top, relatedBy: .equal, toItem: descriptionLabel, attribute: .bottom, multiplier: 1.0, constant: 4.0),
            NSLayoutConstraint(item: priceLabel, attribute: .leading, relatedBy: .equal, toItem: nameLabel, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: priceLabel, attribute: .trailing, relatedBy: .equal, toItem: nameLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: priceLabel, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -8.0)
        ])
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    // Configurar los datos de la celda
    func configure(with product: Producto) {
        nameLabel.text = product.nombre
        descriptionLabel.text = product.descripcion
        priceLabel.text = product.precio

        // Configurar la imagen del producto utilizando una URL o datos de imagen
        if let imageURL = URL(string: product.imagenURL),
           let imageData = try? Data(contentsOf: imageURL),
           let image = UIImage(data: imageData) {
            let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 80.0, height: 80.0)) // Cambiar el tamaño de la imagen según tus necesidades
            productImageView.image = resizedImage
        } else {
            // Si no se puede cargar la imagen, puedes mostrar una imagen de marcador de posición o dejarla vacía
            productImageView.image = UIImage(named: "placeholder")
        }
    }
}




