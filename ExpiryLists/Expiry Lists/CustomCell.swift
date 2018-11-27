//
//  CustomCell.swift
//  Expiry Lists
//
//  Created by King Christopher on 11/26/18.
//  Copyright © 2018 Fontana Technologies. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

   
        @IBOutlet weak var descriptionOutlet: UILabel!
        @IBOutlet weak var skuOutlet: UILabel!
        @IBOutlet weak var dateOutlet: UILabel!
        @IBOutlet weak var categoryOutlet: UILabel!
    
    
    var descriptionName: String = ""{
        didSet{
            
            if(descriptionName != oldValue){
                descriptionOutlet.text = descriptionName
            }
        }
    }
    var skuNumber: String = ""{
        didSet{
            if(skuNumber != oldValue){
                skuOutlet.text = skuNumber
            }
        }
    }
    var dateTime: String = ""{
        didSet{
            
            if(dateTime != oldValue){
                dateOutlet.text = dateTime
            }
        }
    }
    var catName: String = ""{
        didSet{
            
            if(catName != oldValue){
                categoryOutlet.text = catName
            }
        }
    }
}



