//
//  ListViewController.swift
//  BirthdayRememberApp
//
//  Created by Burak on 31.12.2023.
//

import UIKit
import CoreData
class ListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var dateArray = [String]()
    var idArray = [UUID]()
    
    var goingData = ""
    var goingDataId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.lightGray
        takeData()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(takeData), name: NSNotification.Name("newData"), object: nil)
    }
    @objc func takeData(){
        nameArray.removeAll(keepingCapacity: false)
        dateArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Birt")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results =  try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let date = result.value(forKey: "date") as? String{
                        self.dateArray.append(date)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("error")
        }
        
        
    }
    
    
    
    @objc func addButtonClicked(){
        goingData = ""
        performSegue(withIdentifier: "toAddVC", sender: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        content.secondaryText = dateArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddVC"{
            let destinationVC = segue.destination as! ViewController
            destinationVC.comingData = goingData
            destinationVC.comingDataId = goingDataId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goingData = nameArray[indexPath.row]
        goingDataId = idArray[indexPath.row]
        performSegue(withIdentifier: "toAddVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Birt")
            let idString = idArray[indexPath.row].uuidString
            fetch.predicate = NSPredicate(format: "id = %@", idString)
            fetch.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetch)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                dateArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
                
            }catch{
                print("error")
            }
        }
        
    }
    
}
