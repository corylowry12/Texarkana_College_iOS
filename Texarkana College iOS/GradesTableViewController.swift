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
import GoogleMobileAds

extension String {
func toDouble() -> Double? {
    return NumberFormatter().number(from: self)?.doubleValue
 }
}

class GradesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var bannerView: GADBannerView! = GADBannerView(adSize: kGADAdSizeBanner)
    
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
    
    func noGradesStoredBackground() {
        if grades.count == 0 {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: accessibilityFrame.size.width, height: accessibilityFrame.size.height))
            messageLabel.text = "There are currently no grades stored"
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel;
            tableView.separatorStyle = .none;
        }
        else {
            tableView.backgroundView = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-4546055219731501/7993421653"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Grades/\(userDefaults.string(forKey: "id") ?? "")"
        noGradesStoredBackground()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return grades.count + 1
     
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row != 0)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Warning", message: "Would you like to delete this grade? It can not be undone!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                let gradeToDelete = self.grades[indexPath.row - 1]
                self.context.delete(gradeToDelete)
                
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                self.noGradesStoredBackground()
                
                if self.grades.count == 0 {
                    tableView.cellForRow(at: [0, 0])?.isHidden = true
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {_ in
                tableView.setEditing(false, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var classItems : Grades!
        //var cell : UITableViewCell
        if indexPath == [0, 0] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "averageCell", for: indexPath) as! AverageTableViewCell
            //var average = 0.0
            var total = 0.0
            if grades.count > 0 {
            for i in 0...grades.count - 1 {
                total += grades[i].grades * (Double(grades[i].weight))
            }
                var average : Double! = 0.0
                var totalOfWeights = 0
                for i in 0...grades.count - 1 {
                    totalOfWeights += Int(grades[i].weight)
                }
                average += total / Double(totalOfWeights)
            average = round(average * 100.0) / 100.0
                cell.averageLabel.text = "Average: \(average ?? 0.0)"
            return cell
        }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "gradesCell", for: indexPath) as! GradesTableViewCell
           
            classItems = grades[indexPath.row - 1]
          
            let className = classItems.grades
            let gradeWeight = classItems.weight
            let name = classItems.name
            
            cell.nameLabel.text = "Name: \(name ?? "")"
            cell.gradesLabel.text = "Grade: \(className)"
            cell.weightLabel.text = "Weight: \(gradeWeight)"
            print(userDefaults.value(forKey: "id"))
            return cell
        }
        
        
        let tableViewCell = UITableViewCell()
        tableViewCell.isHidden = true
            return tableViewCell
    
    }
    

    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Grade", message: "Add a grade. If left blank it will default to 100", preferredStyle: .alert)
        alert.addTextField { [self] (textField) in
            textField.placeholder = "Name"
        }
        alert.addTextField { [self] (textField) in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Grade"
        }
        alert.addTextField { [self] (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Weight"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            let textFieldName = alert.textFields?[0]
            let textField = alert.textFields?[1]
            let textField1 = alert.textFields?[2]
            if textField?.text == "" ||  textField1!.text == "" {
                let snackbar = TTGSnackbar(message: "Grades were defaulted as 100", duration: .long)
                snackbar.show()
                let classToBeStored = Grades(context: self.context)
                let input : Double = 100.0
                classToBeStored.name = "Exam"
                classToBeStored.grades = input
                classToBeStored.weight = 100
                classToBeStored.id = self.userDefaults.string(forKey: "id")
                classToBeStored.date = Date()
                self.tableView.reloadData()
            }
            else {
            let classToBeStored = Grades(context: self.context)
            let input : Double = (textField?.text?.toDouble())!
                let weight = Int32(((textField1?.text)!))
                classToBeStored.name = textFieldName?.text
            classToBeStored.grades = input
                classToBeStored.weight = weight!
            classToBeStored.id = self.userDefaults.string(forKey: "id")
                classToBeStored.date = Date()
            self.tableView.reloadData()
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.noGradesStoredBackground()
        }))
        
        self.present(alert, animated: true, completion: nil)
  
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0),
            
            ])
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
}
