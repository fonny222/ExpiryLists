//
//  ExpirationListScreenController.swift
//  Expiry Lists
//
//  Created by King Christopher on 8/1/18.
//  Copyright © 2018 Fontana Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ExpirationListScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    @IBOutlet weak var expirationListsTable: UITableView!
    
    
    var ref:DatabaseReference?
    var handle:DatabaseHandle?
    
    var expirationListArray:[String] = []
    var exListIDArray:[String] = []
    
    var selectedRow = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // call a reference to the database when the view loads*****
        ref = Database.database().reference()
        
       
        handle = ref?.child("expiry-lists").child("expiration").observe(.childAdded, with: {(snapshot) in
            if let item = snapshot.value as? [String : String]
            {
                //use this methjod to retrieve what specific data I want
                let text = item["name"]
                let id = item["id"]
                
                // this adds it to the array that fills the table
                self.expirationListArray.append(text!)
                self.exListIDArray.append(id!)
                
                // print to see if anything going in the array
                print()
                print(self.exListIDArray)
                print()
                
                self.expirationListsTable.reloadData()
            }
        })
       
        
    }

    
    
    

    @IBAction func createNewList(_ sender: UIBarButtonItem) {
       // this creates a list using an alert pop up when you hit the plust in the upper corner on the expiration view controller
        // first create the alert controller with text title and message
        let alert = UIAlertController(title: "New List", message: "Add a New Expiration List", preferredStyle: .alert)
        
        // create the button that saves the list as an action
        let saveAction = UIAlertAction(title: "save", style: .default){
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let listToSave = textField.text else{
                    return
            }
            if listToSave != ""
            {
                
                // list to store what you store in the database
                var list = ["name": listToSave, "id": ""]
                
                
                /* ok the line right below this will work normally but I have to get the autoIDKey to store in the database to use later so before it's saved I have to put it in the dictionary that will be saved so I have to split up instead of 1 line into 2
                 */
                //self.ref?.child("expiry-lists").child("expiration").childByAutoId().setValue(list)
                
                let storeRef = self.ref?.child("expiry-lists").child("expiration").childByAutoId()
                
                list["id"] = (storeRef?.key)!
                
                storeRef?.setValue(list)
                
                print()
                print(listToSave)
                print()
            }
        }
        // create the cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        // call the alert and things it does
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    
    // number of rows based on the array count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expirationListArray.count
    }
    
    
    
    // this populates the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = expirationListArray[indexPath.row]
        
        return cell
    }
    
    
    
    // this should delete the row at the index path with a swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
       
        print()
        print(expirationListArray[indexPath.row])
        print()
        
        
        // this will delete the specific child because I'm using the id key
        let childRef = self.ref?.child("expiry-lists").child("expiration").child(exListIDArray[indexPath.row])
        childRef?.removeValue { error, _ in
            print("don't know what this is saying")
            print(error)
            print()
        }
        
        
        // this works to remove the row from the table
        expirationListArray.remove(at: indexPath.row)
        exListIDArray.remove(at: indexPath.row)
        
        print()
        print(exListIDArray)
        print()
        
        self.expirationListsTable.deleteRows(at: [indexPath], with: .fade)
        
        
        /*
         // this is to try to make a pop up before list is deleted need to figure it out still
        let alert = UIAlertController(title: "DELETE LIST!", message: "Are You Sure You Want To Delete This List??", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default){
            [unowned self] action in
            self.ref?.child("expiry-lists").child("expiration").child(self.expirationListArray[indexPath.row]).setValue(nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        */
    }
    
    
    
    
    
    // MARK: - Navigation

    // segue to the next view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // gets the row index of what you selected
        selectedRow = indexPath.row
        
        performSegue(withIdentifier: "toExListChoiceController", sender: cell)
        
    }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /* I probably don't need the if statement but I have it just in case I need to use multiple segues
         */
        if(segue.identifier == "toExListChoiceController"){
        // Get the new view controller using segue.destinationViewController.
        let exListIsNext = segue.destination as! ExListChoiceController
        
        // Pass the selected object to the new view controller.
            var expirationListName = expirationListArray[selectedRow]
            var expirationIDNumber = exListIDArray[selectedRow]
            
            // sends the list and ID to the next view controller
            exListIsNext.expirationList = expirationListName
            exListIsNext.expirationListID = expirationIDNumber
            
        }
    }
}
