//
//  ExListChoiceController.swift
//  Expiry Lists
//
//  Created by King Christopher on 8/7/18.
//  Copyright © 2018 Fontana Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ExListChoiceController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    //outlet for table
    @IBOutlet weak var ExListTableOutlet: UITableView!
    // outlet to change nav bar item
    @IBOutlet weak var navTitle: UINavigationItem!
    
    /* this is for when you eventually select the store I'll just use it
     now so I'll have less to change later.
     TODO: if I go with the store sytem i'll have to come up with a way to recall what store was chosen on log in
     maybe store it locally? otherwise for now I'll just add the variable to each viewcontroller
     */
    var storeNumber = "6226"
    
    var expirationList = ""
    var expirationListID = ""
    
    var selectedRow = -1
    
    // firebase database reference and handle
    var ref:DatabaseReference?
    var handle:DatabaseHandle?
    
    //var ref2:DatabaseReference?
    
    // to load into the table
    var expListArraySKU:[String] = []
    var expListArrayDescrip:[String] = []
    var expListDate:[String] = []
    var newExpListIDArray:[String] = []
    var expCategory:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navTitle.title = expirationList
        
        /* I used the ref code later on so this is redundant right now.*/
        //call a reference to the database when the view loads*****
        ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
        /*
        print()
        print("HELLOOOO it's time to ROCK!!")
        print(expirationList)
        print(expirationListID)
        print()
        */
        // TODO: pull data from specific list using the ID from ExpirationList variable
        /*  OK so I flattened out my database as much as I can
         I added a reference to each of the lists names AutoIDs in the list items json structures
         
         TODO: Only pull List-Data items for the list I select on the first screen.
                    This may need to be a query? of some kind? is that possible?
         
         IT WORKED!!!! I GOT IT WORKING!!! PULLING ONLY THE DATA I NEEDED. I needed to use Query ordered by and queryEqual tovalue I can't believe it.

    
         TODO: index data in firebase, This will allow faster queries so it's not done on the client side.
 */
        
        /*
         TODO: This might be the answer I'm looking for! figure out how to put the values in the arrays to populate the table!!
         OH MY GOD I FIGURED IT OUT POSSIBLY!!!!!! OH MY GOD IT MIGHT ACTUALLY WORK!!
 */
        // testing to get a query this may work to give me specific data I need
        let ref2 = Database.database().reference().child(storeNumber).child("List-Data").queryOrdered(byChild: "list_id").queryEqual(toValue : expirationListID)
       
        ref2.observe(.childAdded, with: {(snapshot) in
            if let item = snapshot.value as? [String : String]
            {
                let desc = item["description"]
                let id = item["id"]
                let expDate = item["expirationDate"]
                let skuNum = item["sku"]
                let categ = item["category"]
                
                self.expListArrayDescrip.append(desc!)
                self.newExpListIDArray.append(id!)
                self.expListArraySKU.append(skuNum!)
                self.expListDate.append(expDate!)
                self.expCategory.append(categ!)
                
                /*
                print()
                print("This is the Id array")
                print(self.newExpListIDArray)
                print()
                 */
                self.ExListTableOutlet.reloadData()
            }
        })
        
        
        /*
         this will hopefully remove  the correct thing when something is removed across devices
         
         TODO: I just realized I'm searching for each of those values in the array and the first time it comes across them it will delete it. If something has a similar name it will have trouble deleting the proper one.
         I need to change it so it finds the id number. this value is unique and I need to then grab that ID Numbers index and use that index to remove the values in the other arrays.
         */
        
        ref?.child(storeNumber).child("List-Data").observe(.childRemoved, with: {(snapshot)
            in
            
            if let item = snapshot.value as? [String : String]
            {
                
                //use this methjod to retrieve what specific data I want
                let desc = item["description"]
               
                /*
                 so I dont think I need to get each thing just the array id
                 */
                /*
                let expDate = item["expirationDate"]
                let skuNum = item["sku"]
                let categ = item["category"]
                */
                // this adds it to the array that fills the table
                // the removAll{} i found finds the string in teh array and removes it
                
                /*
                 I had to add the if statement because If I deleted the row on the device the delete row method would fire as well as the detect change method. So by the time it gets to the remove at index for the arrays the index was already removed in the delete row method and it would crash the program.
                 */
                 let id = item["id"]
                var indexNumber = self.newExpListIDArray.firstIndex(of: id!)
                
                if indexNumber != nil
                {
                self.expListArrayDescrip.remove(at: indexNumber!)
                self.newExpListIDArray.remove(at: indexNumber!)
                self.expListArraySKU.remove(at: indexNumber!)
                self.expListDate.remove(at: indexNumber!)
                self.expCategory.remove(at: indexNumber!)
                
                /*
                // print to see if anything going in the array
                print("This is what is being deleted")
                print(desc)
                print()
                */
                }
            }
          self.ExListTableOutlet.reloadData()
        })
        
        ref?.child(storeNumber).child("List-Data").observe(.childChanged, with: {(snapshot)
            in
            
            if let item = snapshot.value as? [String : String] {
                //use this methjod to retrieve what specific data I want
                let desc = item["description"]
                let id = item["id"]
                let expDate = item["expirationDate"]
                let skuNum = item["sku"]
                let categ = item["category"]
                
                var indexNumber = self.newExpListIDArray.firstIndex(of: id!)
                
                // this adds it to the array that fills the table
                // the removAll{} i found finds the string in teh array and removes it
                self.expListArrayDescrip[indexNumber!] = desc!
                self.expListArraySKU[indexNumber!] = skuNum!
                self.expListDate[indexNumber!] = expDate!
                self.expCategory[indexNumber!] = categ!
                
                /*// print to see if anything going in the array
                print("This is what is being changed")
                print(desc)
                print()
 */
            }
        })
    }


    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expListArrayDescrip.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = expListArrayDescrip[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        /*
        print()
        print("What I'm trying to delete")
        print(newExpListIDArray[indexPath.row])
        print("this is the index path chosen")
        print(indexPath.row)
        */
        /*
         URGENT: I cannot figure out why this will not delete data. The ID and index path is correct this even matches code
         that works from other views somethings missing I cannot see FIGURE THIS OUT!!
         I GOT IT WORKING WOOOOO!
         */
        let childRef3 = Database.database().reference().child(storeNumber).child("List-Data").child(newExpListIDArray[indexPath.row])
        childRef3.removeValue{ error, _ in
            print()
            print("error message")
            print(error)
        }
       
        expListArraySKU.remove(at: indexPath.row)
        expListArrayDescrip.remove(at: indexPath.row)
        expListDate.remove(at: indexPath.row)
        newExpListIDArray.remove(at: indexPath.row)
        expCategory.remove(at: indexPath.row)
        
        self.ExListTableOutlet.deleteRows(at: [indexPath], with: .fade)
    }
    
    //MARK: - Navigation
    // segue to the next view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // gets the row index of what you selected
        selectedRow = indexPath.row
        
        performSegue(withIdentifier: "editExpInfo", sender: cell)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addNewExpItem"){
            
            // get new view controller using segue.destinationViewController
            let addItemController = segue.destination as! AddExpirationItem
            
            // pass the selected List name and ID to the controller
            // and send it to the next view controller
            addItemController.AddExpirationListName = expirationList
            addItemController.AddExpirationListID = expirationListID
        }
        
        if(segue.identifier == "editExpInfo"){
            // get new view controller using segue.destinationViewController
            let addItemController = segue.destination as! AddExpirationItem
            
            // pass the selected List name and ID to the controller
            // and send it to the next view controller
            addItemController.AddExpirationListName = expirationList
            addItemController.AddExpirationListID = expirationListID
            addItemController.expItemID = newExpListIDArray[selectedRow]
            addItemController.expirationDate = expListDate[selectedRow]
            addItemController.expirationDesc = expListArrayDescrip[selectedRow]
            addItemController.expirationSKU = expListArraySKU[selectedRow]
            addItemController.expirationCategory = expCategory[selectedRow]
        }
    }
    

}









// extra code I may not need

/*
 // this will pull all the data for all the lists Not the specific ones I need.
 handle = ref?.child("List-Data").observe(.childAdded, with: {(snapshot) in
 if let item = snapshot.value as? [String : String]
 {
 // just testing the what pulls if it works add the other fields
 let desc = item["description"]
 let id = item["id"]
 
 // add them to the array
 self.expListArrayDescrip.append(desc!)
 self.newExpListIDArray.append(id!)
 
 // print to see if anything is in the array
 print()
 print(self.expListArrayDescrip)
 print(self.newExpListIDArray)
 print()
 
 self.ExListTableOutlet.reloadData()
 }
 })
 */
