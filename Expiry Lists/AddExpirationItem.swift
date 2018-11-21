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


class AddExpirationItem: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
   
    /*
     NOTE: I may not need to pass all the variables, maybe just the indivitual item ID as well as the list ID
     I decided to just pass the variables since I have them already and it's easy to pass to the next view. It may be more efficient.
     */
    // variables to fill
    var expirationDate = ""
    var expirationSKU = ""
    var expirationDesc = ""
    var expirationCategory = ""
    
    var valueSelected = ""
    
    var expItemID = ""
    var AddExpirationListID = ""
    var AddExpirationListName = ""
    
    let pickerCategoryArray = ["Cookies", "Baking","Candy","Chocolate","Savories","Drinks","Snacks"]
    
    /* this is for when you eventually select the store I'll just use it
     now so I'll have less to change later.
     TODO: if I go with the store sytem i'll have to come up with a way to recall what store was chosen on log in
     maybe store it locally? otherwise for now I'll just add the variable to each viewcontroller
     */
    var storeNumber = "6226"
    
    @IBOutlet weak var skuOutlet: UITextField!
    @IBOutlet weak var describeOutlet: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerCategoryOutlet: UIPickerView!
    
    
    
    // database reference and handler
    var ref:DatabaseReference?
    var handle:DatabaseHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if expItemID != "" {
            convertTheDate()
            setTextFields()
        }
        
        // this grabs the default value of the picker and assigns it to the value selected variable until a new one is selected
         valueSelected = pickerCategoryArray[pickerCategoryOutlet.selectedRow(inComponent: 0)]
        /*
        print()
        print("Wooooo Dawgggy!")
        print(AddExpirationListID, ", ", AddExpirationListName, "This is the item ID", expItemID)
        print()
 */
 
        // call a reference to the database when the view loads****
        ref = Database.database().reference()
        
        
        /*
         TO CONSIDER: maybe I don't want it to change the date/ limit the minimum to current date, if I check a list after the date and click on a cell accidentally it could change the date when I don't want it to.
         */
        // this sets the minimum date to the current date
        // you could do datePicker.maximumDate = Date() for the max date
        //datePicker.minimumDate = Date()
        
        // this is for the text field to dismiss the keyboard when finsihed typing and hit done
       self.describeOutlet.delegate = self
        self.skuOutlet.delegate = self
    }

    /*This function sets the date
     I used a separate function to clearn up the view did load.
     */
    func convertTheDate(){
        
         // this converts the date
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MM/dd/yyyy"
         let dateConvert = dateFormatter.date(from: expirationDate)
         //this sets the date on the picker
         datePicker.setDate(dateConvert!, animated: false)
    }
    
    /*
     this function sets the text fields should only be called if the individule item ID is sent to the view
     
     TODO: SET DEFAULT VALUE OF PICKER WHEN YOU ARE EDITING THE INPUT!***********
     */
    func setTextFields(){
        skuOutlet.text = expirationSKU
        describeOutlet.text = expirationDesc
        
       //this figures out the index to set the picker to for the category when editing data
        var i = 0
        while i < 7{
            if(expirationCategory == pickerCategoryArray[i]){
                pickerCategoryOutlet.selectRow(i, inComponent: 0, animated: false)
            }
            i = i + 1
        }
    }
    
    // save data
    // when I add an item here it makes it so the ExpirationListScreenController does not load the names of the list for the table anymore. I can't figure this out.
    // TODO: FIGURE THIS OUT!!!
    /*
     SOLUTION!  Ok I got rid of the extra level in each branch Instead of Expiry-list > EXpiration > ID > list name and id > list
    it goes Expiry-List > ID list name and id
     then I have List -Data > list ID > Id > list information
     This seems to have flattened out the branches hopefully this will work for everything even deletes.
     
     SOLUTION 2! Solution one didn't seem to flatten it out I know solution 1 would work but can't find a way to get it to pull data
     so I am storing the reference to the list id in the json  branch.  Each entry will just have one level of auto ID I should be able to pull the right data and also look for specific data to delete. lets HOPE this works...
     
     It pulls the data!!! Now I have to figure out how to pull the specific data for the specific list I select!
     
    11-12-18 I GOT IT TO PULL THE CORRECT DATA! so the solution works!
     */
    @IBAction func saveData(_ sender: UIButton) {
        
        // get the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        expirationDate = dateFormatter.string(from: datePicker.date)
        
        
        if skuOutlet.text != "" && describeOutlet.text != "" && expItemID == ""{
            let skuText = skuOutlet.text
            let description = describeOutlet.text
            let category = valueSelected
            
            var listEntry = ["sku": skuText, "description": description, "category": category, "expirationDate": expirationDate, "list_id": AddExpirationListID, "id": ""]
            /*
            print()
            print("What's being stored in AddExpirationItem.swift")
            print(listEntry)
            print()
            */
            
            /*
             this creates a child node of the list name that has all the entries to the list
             */
            let storeRef = self.ref?.child(storeNumber).child("List-Data").childByAutoId()
            
            listEntry["id"] = (storeRef?.key)!
            
            storeRef?.setValue(listEntry)
        }
        
        // if there is an ID already then it should do this save
        //if not then it will save the first one
        if expItemID != ""{
            let firRef = Database.database().reference().child(storeNumber).child("List-Data").child(expItemID)
            
            let skuText = skuOutlet.text
            let description = describeOutlet.text
            let category = valueSelected
            
            print()
            print("Category: ", category)
            
            
            var listEntry = ["sku": skuText, "description": description, "category": category, "expirationDate": expirationDate]
            firRef.updateChildValues(listEntry)
        }
        
        // this should pop the view back to the other screen after hitting the save button
        navigationController?.popViewController(animated: true)
        
    }
    
    
    // get rid of keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    // picker view delegates and data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCategoryArray.count
    }
 
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerCategoryArray[row]
    }
    
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueSelected = pickerCategoryArray[row]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
