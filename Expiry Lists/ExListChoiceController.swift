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

class ExListChoiceController: UIViewController {
    
    var expirationList = ""
    var expirationListID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print()
        print("HELLOOOO it's time to ROCK!!")
        print(expirationList)
        print(expirationListID)
        print()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

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
    }
    

}
