//
//  InventarioViewController.swift
//  BuzzBuy-ecommerce
//
//  Created by Robert Charca on 16/06/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class InventarioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableInventario: UITableView!
    
    var productos:[Producto] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let producto = productos[indexPath.row]
        cell.textLabel?.text = producto.nombre
        cell.detailTextLabel?.text = producto.descripcion
        
        return cell
    }
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInventario.dataSource = self
        tableInventario.delegate = self
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
