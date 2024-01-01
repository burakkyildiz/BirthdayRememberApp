//
//  ViewController.swift
//  BirthdayRememberApp
//
//  Created by Burak on 30.12.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var birthdayMessageText: UITextField!
    @IBOutlet weak var birthdayDateText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    var comingData = ""
    var comingDataId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if comingData != ""{
            //coreData
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Birt")
            let idString = comingDataId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let date = result.value(forKey: "date") as? String{
                            birthdayDateText.text = date
                        }
                        if let message = result.value(forKey: "message") as? String{
                            birthdayMessageText.text = message
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("error")
            }
            
            
            
            
        }else{
            
        }
        
        
        //Gesture Recognizer
        let keyboardRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(keyboardRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageRecognizer)

    }
    
    
    
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
        
    }
    
    @IBAction func addToListCicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newBirt = NSEntityDescription.insertNewObject(forEntityName: "Birt", into: context)
        
        newBirt.setValue(nameText.text, forKey: "name")
        newBirt.setValue(birthdayDateText.text, forKey: "date")
        newBirt.setValue(birthdayMessageText.text, forKey: "message")
        newBirt.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newBirt.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("save success")
        }catch{
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

