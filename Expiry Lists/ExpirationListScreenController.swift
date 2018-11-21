//
//  ExpirationListScreenController.swift
//  Expiry Lists
//
//  Created by King Christopher on 8/1/18.
//  Copyright © 2018 Fontana Technologies. All rights reserved.
//

/*
 TODO: when i delete on one device it doesn't remove it from the table on another device
 figure out how to referesh the table/array holding data on all devices in the app when it detects something was deleted.
 */
import UIKit
import Firebase
import FirebaseAuth

class ExpirationListScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    @IBOutlet weak var expirationListsTable: UITableView!
    
    /* this is for when you eventually select the store I'll just use it
     now so I'll have less to change later.
     TODO: if I go with the store sytem i'll have to come up with a way to recall what store was chosen on log in
     maybe store it locally? otherwise for now I'll just add the variable to each viewcontroller
     */
    var storeNumber = "6226"
    
    var ref:DatabaseReference?
    var handle:DatabaseHandle?
    
    var expirationListArray:[String] = []
    var exListIDArray:[String] = []
    
    //this is for deleting the node
     var deletedListNodeID:[String] = []
    
    var selectedRow = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // call a reference to the database when the view loads*****
        ref = Database.database().reference()
        
       // This does not load after I add an item from the AddExpirationItem.swift class I don't know why
        //TODO: FIGURE THIS OUT!!!
        //FIXED IT!  But I still don't know why it works now...
        handle = ref?.child(storeNumber).child("expiry-lists").observe(.childAdded, with: {(snapshot) in
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
       
        
        /*
         update: I FIGURED IT OUT!
         snapshot returns what was deleted so I can use that to find out what needs to be removed in teh array!
         */
        
        ref?.child(storeNumber).child("expiry-lists").observe(.childRemoved, with: {(snapshot)
            in
            
           
            
             // this does nothing but add back what was deleted to the arrays...
            if let item = snapshot.value as? [String : String]
            {
                
                //use this methjod to retrieve what specific data I want
                let text = item["name"]
                let id = item["id"]
                
                // this adds it to the array that fills the table
                // the removAll{} i found finds the string in teh array and removes it
                self.expirationListArray.removeAll{$0 == text}
                self.exListIDArray.removeAll{$0 == id}
                
                // print to see if anything going in the array
                print("This is what is being deleted")
                print(text)
                print()
            }
            
       self.expirationListsTable.reloadData()
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
                
                let storeRef = self.ref?.child(self.storeNumber).child("expiry-lists").childByAutoId()
                
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
       
        
        // this will delete the specific child because I'm using the id key and it deletes just the list name
        let childRef = self.ref?.child(storeNumber).child("expiry-lists").child(exListIDArray[indexPath.row])
        childRef?.removeValue { error, _ in
            print()
            print("don't know what this is saying")
            print(error)
            print()
        }
        
        loadDeletedChilds(listID: exListIDArray[indexPath.row])
        
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
    
    // this loads all the nodes that have an id that matches the list ID and deletes them with a nested delete!
    func loadDeletedChilds(listID:String){
        /*This is my attempt at deleting the list name and the list childs
         MY IDEA: grab the ids of the ones with the matching list and add them to an array, then
         delete all the nodes with those ids somehow... maybe nest within this query if statement
         don't forget to clear the array after delete
         THIS WORKED I NESTED THEM!
         */
        let childRef2 = Database.database().reference().child(storeNumber).child("List-Data").queryOrdered(byChild: "list_id").queryEqual(toValue: listID)
        
        childRef2.observe(.childAdded, with: {(snapshot) in
            if let item = snapshot.value as? [String : String]
            {
                let id = item["id"]
                
                self.deletedListNodeID.append(id!)
                
                
                //lets see if we can nest this!
                //  NESTED SUCCESSFULY!
                let newRef = self.ref?.child(self.storeNumber).child("List-Data").child(id!)
                newRef?.removeValue {error, _ in
                    print()
                    print("another error")
                    print(error)
                    print()
                }
                self.deletedListNodeID.removeAll()
            }
        })
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
