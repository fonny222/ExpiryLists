//
//  AddExpirationItem.swift
//  Expiry Lists
//
//  Created by King Christopher on 8/19/18.
//  Copyright © 2018 Fontana Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


/*
 */


class AddExpirationItem: UIViewController, UITextFieldDelegate {
    
    var AddExpirationListName = ""
    var AddExpirationListID = ""
    

    @IBOutlet weak var skuOutlet: UITextField!
    @IBOutlet weak var describeOutlet: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    // database reference and handler
    var ref:DatabaseReference?
    var handle:DatabaseHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print()
        print("Wooooo Dawgggy!")
        print(AddExpirationListID, ", ", AddExpirationListName)
        print()
        // call a reference to the database when the view loads****
        ref = Database.database().reference()
        
        // this is for the text field to dismiss the keyboard when finsihed typing and hit done
       self.describeOutlet.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // save data
    @IBAction func saveData(_ sender: UIButton) {
        
        if skuOutlet.text != "" && describeOutlet.text != ""{
            let skuText = skuOutlet.text
            let description = describeOutlet.text
            
            var listEntry = ["sku": skuText, "description": description, "expirationDate": "01/01/2018", "id": ""]
            
            print()
            print("This is the Dawning of the age of Aquarius")
            print(listEntry)
            print()
            
            /*
             this creates a child node of the list name that has all the entries to the list
             */
            let storeRef = self.ref?.child("expiry-lists").child("expiration").child(AddExpirationListID).child("list").childByAutoId()
            
            listEntry["id"] = (storeRef?.key)!
            
            storeRef?.setValue(listEntry)
        }
        
        
    }
    
    
    // get rid of keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
  
    
    
    
    /*
    func textFieldShouldReturn(describeOutlet: UITextField!) -> Bool {
        describeOutlet.resignFirstResponder()
        return true;
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
