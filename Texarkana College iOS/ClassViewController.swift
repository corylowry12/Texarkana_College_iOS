//
//  ClassViewController.swift
//  Texarkana College
//
//  Created by Cory Lowry on 8/4/21.
//

import Foundation
import UIKit
import CoreData
import TTGSnackbar
import GoogleMobileAds

class ClassViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var bannerView: GADBannerView! = GADBannerView(adSize: kGADAdSizeBanner)
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var predicateText : String!
    
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
    
    var grades: [Grades] {
        
        do {
            let fetchrequest = NSFetchRequest<Grades>(entityName: "Grades")
            let predicate = predicateText
            fetchrequest.predicate = NSPredicate(format: "id == %@", predicate!)
            let sort = NSSortDescriptor(key: #keyPath(Grades.date), ascending: false)
            fetchrequest.sortDescriptors = [sort]
            return try context.fetch(fetchrequest)
            
        } catch {
            
            print("Couldn't fetch data")
            
        }
        
        return [Grades]()
        
    }
    
    func noClassesStoredBackground() {
        if classes.count == 0 {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: accessibilityFrame.size.width, height: accessibilityFrame.size.height))
            messageLabel.text = "There are currently no classes stored"
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
        noClassesStoredBackground()
        tableView.dataSource = self
        tableView.delegate = self
        
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-4546055219731501/7993421653"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noClassesStoredBackground()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let currentCell = tableView.cellForRow(at: indexPath) as! TableViewCell
        
        let celltext = currentCell.classLabel.text
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(celltext, forKey: "id")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let classItems = classes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! TableViewCell
        
        let className = classItems.class_name
        
        
        cell.classLabel.text = "\(className ?? "")"
        
        let lblNameInitialize = UILabel()
        lblNameInitialize.frame.size = CGSize(width: 50.0, height: 50.0)
        lblNameInitialize.textColor = UIColor.white
        var twoLetters = [String]()
        var text : String!
        
        if ((cell.classLabel.text?.trimmingCharacters(in: .whitespaces))?.contains(" ") == false)  {
            
            text = "\(cell.classLabel.text?.prefix(1) ?? "")"
            print("no whitespace")
        }
        else {
            twoLetters = cell.classLabel.text!.split{$0 == " "}.map(String.init)
            let firstLetter = twoLetters[0].prefix(1)
            let secondLetter = twoLetters[1].prefix(1)
            text = "\(firstLetter)\(secondLetter)"
        }
        
        lblNameInitialize.text = "\(text ?? "C") "
        lblNameInitialize.textAlignment = NSTextAlignment.center
        if text == "M" || text == "m" {
            lblNameInitialize.backgroundColor = UIColor.systemBlue
        }
        else if text == "E" || text == "e" {
            lblNameInitialize.backgroundColor = UIColor.systemRed
        }
        else {
            lblNameInitialize.backgroundColor = UIColor.systemOrange
        }
        lblNameInitialize.layer.cornerRadius = 50.0
        lblNameInitialize.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
        lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
        cell.logo.image = UIGraphicsGetImageFromCurrentImageContext()
        cell.logo.layer.cornerRadius = cell.logo.frame.width / 2
        
        UIGraphicsEndImageContext()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Warning", message: "This will delete the class as well as the grades for this class. Would you like to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                let classToDelete = self.classes[indexPath.row]
                
                let currentCell = tableView.cellForRow(at: indexPath) as! TableViewCell
                self.predicateText = currentCell.classLabel.text
                
                //print(self.predicateText)
                
                self.context.delete(classToDelete)
                
                self.tableView.deleteRows(at: [indexPath], with: .left)
                if self.grades.count > 0 {
                    for i in (0...self.grades.count - 1).reversed() {
                        let gradeToDelete = self.grades[i]
                        self.context.delete(gradeToDelete)
                    }
                }
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.noClassesStoredBackground()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {_ in
                self.tableView.setEditing(false, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Class", message: "Add a class", preferredStyle: .alert)
        alert.addTextField { (textField) in
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [self]_ in
            let textField = alert.textFields?[0]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Classes")
            let predicate = textField!.text!
            let predicateID = NSPredicate(format: "class_name LIKE %@", predicate as CVarArg)
            fetchRequest.predicate = predicateID
            do {
                
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    let snackbar = TTGSnackbar(message: "Item already exists", duration: .long)
                    snackbar.show()
                }else {
                    if textField?.text?.trimmingCharacters(in: .whitespaces) != "" {
                        let classToBeStored = Classes(context: self.context)
                        
                        classToBeStored.class_name = textField?.text?.trimmingCharacters(in: .whitespaces)
                        
                        self.tableView.reloadData()
                        
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    }
                    else {
                        let snackbar = TTGSnackbar(message: "Nothing was stored, you left the text field blank", duration: .long)
                        snackbar.show()
                    }
                }
                noClassesStoredBackground()
            }
            catch let error {
                print(error.localizedDescription)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
