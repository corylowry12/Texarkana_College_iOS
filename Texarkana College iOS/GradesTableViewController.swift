//
//  GradesTableViewController.swift
//  Texarkana College
//
//  Created by Cory Lowry on 8/4/21.
//

import Foundation

import UIKit
import CoreData
import TTGSnackbar

extension String {
func toDouble() -> Double? {
    return NumberFormatter().number(from: self)?.doubleValue
 }
}

class GradesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var grades: [Grades] {
        
        do {
            let fetchrequest = NSFetchRequest<Grades>(entityName: "Grades")
            let predicate = userDefaults.value(forKey: "id") ?? ""
            fetchrequest.predicate = NSPredicate(format: "id == %@", predicate as! CVarArg)
            let sort = NSSortDescriptor(key: #keyPath(Grades.date), ascending: false)
            fetchrequest.sortDescriptors = [sort]
            return try context.fetch(fetchrequest)

        } catch {
            
            print("Couldn't fetch data")
            
        }
        
        return [Grades]()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return grades.count + 1
     
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var classItems : Grades!
        //var cell : UITableViewCell
        if indexPath == [0, 0] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "averageCell", for: indexPath) as! AverageTableViewCell
            var average = 0.0
            var total = 0.0
            for i in 0...grades.count - 1 {
                total += grades[i].grades
            }
            average = round(total / Double(grades.count) * 100.0) / 100.0
            cell.averageLabel.text = "Average: \(average)"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "gradesCell", for: indexPath) as! GradesTableViewCell
           
            classItems = grades[indexPath.row - 1]
          
            let className = classItems.grades
            let gradeWeight = classItems.weight
            
            cell.gradesLabel.text = "\(className)"
            cell.weightLabel.text = "\(gradeWeight)"
            
            return cell
        }
            return UITableViewCell()
    
    }
    

    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Grade", message: "Add a grade. If left blank it will default to 100", preferredStyle: .alert)
        alert.addTextField { [self] (textField) in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Grade"
        }
        alert.addTextField { [self] (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Weight"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            let textField = alert.textFields?[0]
            let textField1 = alert.textFields?[1]
            if textField?.text == "" ||  textField1!.text == "" {
                let snackbar = TTGSnackbar(message: "Grades were defaulted as 100", duration: .long)
                snackbar.show()
                let classToBeStored = Grades(context: self.context)
                let input : Double = 100.0
                classToBeStored.grades = input
                classToBeStored.id = self.userDefaults.string(forKey: "id")
                classToBeStored.date = Date()
                self.tableView.reloadData()
            }
            else {
            let classToBeStored = Grades(context: self.context)
            let input : Double = (textField?.text?.toDouble())!
            classToBeStored.grades = input
            classToBeStored.id = self.userDefaults.string(forKey: "id")
                classToBeStored.date = Date()
            self.tableView.reloadData()
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }))
        
        self.present(alert, animated: true, completion: nil)
  
    }
}
