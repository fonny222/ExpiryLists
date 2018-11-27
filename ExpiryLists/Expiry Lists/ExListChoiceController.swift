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

//TODO: CREATE THE CUSTOM CELLS!!

class ExListChoiceController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    //outlet for table
    @IBOutlet weak var ExListTableOutlet: UITableView!
    // outlet to change nav bar item
    @IBOutlet weak var navTitle: UINavigationItem!
    // outlet for the segmented Controller
    @IBOutlet weak var segmentSelectOutlet: UISegmentedControl!
    
    
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
    
    // to load into the table
    var expListArraySKU:[String] = []
    var expListArrayDescrip:[String] = []
    var expListDate:[String] = []
    var newExpListIDArray:[String] = []
    var expCategory:[String] = []
    
    
    // these are the sorted arrays
    var sortedCatArray:[String] = []
    var sortedDescArray:[String] = []
    var sortedSKUArray:[String] = []
    var sortedDateArray:[String] = []
    var sortedIDArray:[String] = []
    
    
    //These are the arrays with everycategory
    var fullCatArray:[String] = []
    var fullDescArray:[String] = []
    var fullSKUArray:[String] = []
    var fullDateArray:[String] = []
    var fullIDArray:[String] = []
    
    // this is for the hamburger button to display the menu
    var hamburgerMenuIsVisible = false
    
    var combinedArray:[String] = ["Expires,SKU,Description,Category\n"]
    
    //I need this for creating the table cells...for some reason
    let cellTableIdentifier = "CustomCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navTitle.title = expirationList
        
        /* I used the ref code later on so this is redundant right now.*/
        //call a reference to the database when the view loads*****
        ref = Database.database().reference()
        
       
        /*TODO: Only pull List-Data items for the list I select on the first screen.
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
                
                //I'm going to try something new
            /*First fill the full array, then call the sort function sort into the array that fills the tables*/
                /*
                self.expListArrayDescrip.append(desc!)
                self.newExpListIDArray.append(id!)
                self.expListArraySKU.append(skuNum!)
                self.expListDate.append(expDate!)
                self.expCategory.append(categ!)
                */
                self.fullDescArray.append(desc!)
                self.fullIDArray.append(id!)
                self.fullSKUArray.append(skuNum!)
                self.fullDateArray.append(expDate!)
                self.fullCatArray.append(categ!)
                
                self.sortArrayFunction(segIndex: self.segmentSelectOutlet.selectedSegmentIndex)
                
                print()
                print(".childAdded segment index")
                print(self.segmentSelectOutlet.selectedSegmentIndex)
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
                var indexNumber = self.fullIDArray.firstIndex(of: id!)
                
                if indexNumber != nil
                {
                    /*
                self.expListArrayDescrip.remove(at: indexNumber!)
                self.newExpListIDArray.remove(at: indexNumber!)
                self.expListArraySKU.remove(at: indexNumber!)
                self.expListDate.remove(at: indexNumber!)
                self.expCategory.remove(at: indexNumber!)
                */
                
                    self.fullDescArray.remove(at: indexNumber!)
                    self.fullIDArray.remove(at: indexNumber!)
                    self.fullSKUArray.remove(at: indexNumber!)
                    self.fullDateArray.remove(at: indexNumber!)
                    self.fullCatArray.remove(at: indexNumber!)
                    
                    self.sortArrayFunction(segIndex: self.segmentSelectOutlet.selectedSegmentIndex)
                    print()
                    print(".childRemoved segment index")
                    print(self.segmentSelectOutlet.selectedSegmentIndex)
                }
            }
        })
        
        ref?.child(storeNumber).child("List-Data").observe(.childChanged, with: {(snapshot)
            in
            print("This is the Before")
            print(self.expListArrayDescrip)
            print()
            if let item = snapshot.value as? [String : String] {
                //use this methjod to retrieve what specific data I want
                let desc = item["description"]
                let id = item["id"]
                let expDate = item["expirationDate"]
                let skuNum = item["sku"]
                let categ = item["category"]
                // test
                //var indexNumber = self.newExpListIDArray.firstIndex(of: id!)
                
                var indexNumber = self.fullIDArray.firstIndex(of: id!)
                
                // this adds it to the array that fills the table
                // the removAll{} i found finds the string in teh array and removes it
                /*
                self.expListArrayDescrip[indexNumber!] = desc!
                self.expListArraySKU[indexNumber!] = skuNum!
                self.expListDate[indexNumber!] = expDate!
                self.expCategory[indexNumber!] = categ!
                */
                
                self.fullDescArray[indexNumber!] = desc!
                self.fullIDArray[indexNumber!] = id!
                self.fullSKUArray[indexNumber!] = skuNum!
                self.fullDateArray[indexNumber!] = expDate!
                self.fullCatArray[indexNumber!] = categ!
                
                self.sortArrayFunction(segIndex: self.segmentSelectOutlet.selectedSegmentIndex)
               
                print()
                print(".childChanged segment index")
                print(self.segmentSelectOutlet.selectedSegmentIndex)
            }
        })
        
        // this sets the cell height to whatever you want
        ExListTableOutlet.rowHeight = 200
        ExListTableOutlet.register(CustomCell.self, forCellReuseIdentifier: cellTableIdentifier)
        //connect the custom cell to the table
        let xib = UINib(nibName: "CustomTableCell", bundle: nil)
        ExListTableOutlet.register(xib, forCellReuseIdentifier: cellTableIdentifier)
        
        
    }


    /*
     TODO: figure out how to sort the arrays that doesn't mess with the change/removed/added structures
     I need to sort the data. But if i change the arrays then when something gets added or removed it will mess up the array that is being used to display the sorted data.
     
     UPDATE: FIGURED IT OUT!!
     */
    //segment sorting
    @IBAction func segmentedSelectionAction(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            sortArrayFunction(segIndex: sender.selectedSegmentIndex)
            
        case 1:
            sortArrayFunction(segIndex: sender.selectedSegmentIndex)
        case 2:
            sortArrayFunction(segIndex: sender.selectedSegmentIndex)
        case 3:
            sortArrayFunction(segIndex: sender.selectedSegmentIndex)
        case 4:
            sortArrayFunction(segIndex: sender.selectedSegmentIndex)
        case 5:
            sortArrayFunction(segIndex: sender.selectedSegmentIndex)
        default:
            break;
        }
    }
    
    
    //this function will sort the arrays
    func sortArrayFunction(segIndex: Int)
    {
        switch segIndex {
        case 0:
            print("All")
            
            clearArrays()
            
            // this fills the array that loads the table
            expListArraySKU = fullSKUArray
            expListArrayDescrip = fullDescArray
            expListDate = fullDateArray
            newExpListIDArray = fullIDArray
            expCategory = fullCatArray
            
            ExListTableOutlet.reloadData()
            
        case 1:
            print("Cookies/Baking")
            
            clearArrays()
            
            var i = 0
            
            while i < fullCatArray.count {
                var cat = "Cookies"
                var cat2 = "Baking"
                
                if cat == fullCatArray[i] || cat2 == fullCatArray[i] {
                    sortedCatArray.append(fullCatArray[i])
                    sortedDescArray.append(fullDescArray[i])
                    sortedSKUArray.append(fullSKUArray[i])
                    sortedDateArray.append(fullDateArray[i])
                    sortedIDArray.append(fullIDArray[i])
                }
                i = i + 1
            }
            // this fills the array that loads the table
            expListArraySKU = sortedSKUArray
            expListArrayDescrip = sortedDescArray
            expListDate = sortedDateArray
            newExpListIDArray = sortedIDArray
            expCategory = sortedCatArray
            
            ExListTableOutlet.reloadData()
            
            print("This is what is being added..")
            print(sortedDescArray)
            
        case 2:
            print("Candy")
            
            clearArrays()
            
            var i = 0
            
            while i < fullCatArray.count {
                var cat = "Candy"
                
                if cat == fullCatArray[i] {
                    sortedCatArray.append(fullCatArray[i])
                    sortedDescArray.append(fullDescArray[i])
                    sortedSKUArray.append(fullSKUArray[i])
                    sortedDateArray.append(fullDateArray[i])
                    sortedIDArray.append(fullIDArray[i])
                }
                i = i + 1
            }
            
            // this fills the array that loads the table
            expListArraySKU = sortedSKUArray
            expListArrayDescrip = sortedDescArray
            expListDate = sortedDateArray
            newExpListIDArray = sortedIDArray
            expCategory = sortedCatArray
            
            ExListTableOutlet.reloadData()
            
        case 3:
            print("Savories")
            
           clearArrays()
            
            var i = 0
            
            while i < fullCatArray.count {
                var cat = "Savories"
                
                if cat == fullCatArray[i] {
                    sortedCatArray.append(fullCatArray[i])
                    sortedDescArray.append(fullDescArray[i])
                    sortedSKUArray.append(fullSKUArray[i])
                    sortedDateArray.append(fullDateArray[i])
                    sortedIDArray.append(fullIDArray[i])
                }
                i = i + 1
            }
            
            // this fills the array that loads the table
            expListArraySKU = sortedSKUArray
            expListArrayDescrip = sortedDescArray
            expListDate = sortedDateArray
            newExpListIDArray = sortedIDArray
            expCategory = sortedCatArray
            
            ExListTableOutlet.reloadData()
            
        case 4:
            print("Drinks")
            
        clearArrays()
            
            var i = 0
            
            while i < fullCatArray.count {
                var cat = "Drinks"
                
                if cat == fullCatArray[i] {
                    sortedCatArray.append(fullCatArray[i])
                    sortedDescArray.append(fullDescArray[i])
                    sortedSKUArray.append(fullSKUArray[i])
                    sortedDateArray.append(fullDateArray[i])
                    sortedIDArray.append(fullIDArray[i])
                }
                i = i + 1
            }
            
            // this fills the array that loads the table
            expListArraySKU = sortedSKUArray
            expListArrayDescrip = sortedDescArray
            expListDate = sortedDateArray
            newExpListIDArray = sortedIDArray
            expCategory = sortedCatArray
            
            ExListTableOutlet.reloadData()
            
        case 5:
            print("Snacks")
            
            clearArrays()
            
            var i = 0
            
            while i < fullCatArray.count {
                var cat = "Snacks"
                
                if cat == fullCatArray[i] {
                    sortedCatArray.append(fullCatArray[i])
                    sortedDescArray.append(fullDescArray[i])
                    sortedSKUArray.append(fullSKUArray[i])
                    sortedDateArray.append(fullDateArray[i])
                    sortedIDArray.append(fullIDArray[i])
                }
                i = i + 1
            }
            
            // this fills the array that loads the table
            expListArraySKU = sortedSKUArray
            expListArrayDescrip = sortedDescArray
            expListDate = sortedDateArray
            newExpListIDArray = sortedIDArray
            expCategory = sortedCatArray
            
            ExListTableOutlet.reloadData()
            
        default:
            break;
        }
    }
    
    func clearArrays(){
        // these clear the arrays so sort doesnt add more to them.
        expListArraySKU.removeAll()
        expListArrayDescrip.removeAll()
        expListDate.removeAll()
        newExpListIDArray.removeAll()
        expCategory.removeAll()
        
        //these clear the sorted arrays
        sortedCatArray.removeAll()
        sortedDescArray.removeAll()
        sortedSKUArray.removeAll()
        sortedDateArray.removeAll()
        sortedIDArray.removeAll()
    }
    
    /*
     outlets for the hamburger btn and the action to move the screen
     */
    
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    
    
    @IBAction func hamburgerBtnAction(_ sender: UIBarButtonItem) {
        
        if !hamburgerMenuIsVisible {
            leadingC.constant = 100
            //trailingC.constant = 100
            
            hamburgerMenuIsVisible = true
        }
        
        else{
            leadingC.constant = 0
            trailingC.constant = 0
            
            hamburgerMenuIsVisible = false
        }
        
        // this is to animate the transition
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) {(animationComplete) in
            print("the Animation is complete!")
    }
}
    
    /*
     this should create the list and pop up the option to email it to the email of your choice
     */
    @IBAction func emailButton(_ sender: UIButton) {
        
        var i = 0
        
        while i < newExpListIDArray.count {
            
            var combined = "\(expListDate[i]),\(expListArraySKU[i]),\(expListArrayDescrip[i]),\(expCategory[i])\n"
            combinedArray.append(combined)
            i = i + 1
        }
        
        createCSV()
        sendFile()
    }
    
    /*these functions should create the CSV file in the temporary directory and then send the file*/
    
    func createCSV(){
        let fileName = "expirationList.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var arrayJoined = ""
        arrayJoined = combinedArray.joined(separator: " ")
        
        do {
            try arrayJoined.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        }catch{
            print("Failed to create csv file")
            print("\(error)")
        }
    }
    
    func sendFile(){
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("expirationList.csv")
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
 
 
 
 
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expListArrayDescrip.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         // this is what I originally had
         let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = expListArrayDescrip[indexPath.row]
        */
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as! CustomCell
        
        //these are the variables from the CustomCell Class to fill thep rototype cell
        cell.descriptionName = expListArrayDescrip[indexPath.row]
        cell.skuNumber = expListArraySKU[indexPath.row]
        cell.dateTime = expListDate[indexPath.row]
        cell.catName = expCategory[indexPath.row]
        
        
        
        
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
        
        fullSKUArray.remove(at: indexPath.row)
        fullDescArray.remove(at: indexPath.row)
        fullDateArray.remove(at: indexPath.row)
        fullIDArray.remove(at: indexPath.row)
        fullCatArray.remove(at: indexPath.row)
        
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
