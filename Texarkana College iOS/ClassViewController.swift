//
//  ClassViewController.swift
//  Texarkana College
//
//  Created by Cory Lowry on 8/4/21.
//

import Foundation
import UIKit
import CoreData

class ClassViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var classes: [Classes] {
        
        do {
            let fetchrequest = NSFetchRequest<Classes>(entityName: "Classes")
            let sort = NSSortDescriptor(key: #keyPath(Classes.class_name), ascending: false)
            fetchrequest.sortDescriptors = [sort]
            return try context.fetch(fetchrequest)
            
        } catch {
            
            print("Couldn't fetch data")
            
        }
        
        return [Classes]()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let currentCell = tableView.cellForRow(at: indexPath) as! TableViewCell

        let celltext = currentCell.classLabel.text
            let userDefaults = UserDefaults.standard
        userDefaults.setValue(celltext, forKey: "id")
        //print(celltext)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let classItems = classes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! TableViewCell
      
        let className = classItems.class_name
        
        
        cell.classLabel.text = "\(className ?? "")"
        
        return cell
    }
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Class", message: "Add a class", preferredStyle: .alert)
        alert.addTextField { [self] (textField) in
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            let textField = alert.textFields?[0]
           
            let classToBeStored = Classes(context: self.context)
            
            classToBeStored.class_name = textField?.text
            
            self.tableView.reloadData()
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
