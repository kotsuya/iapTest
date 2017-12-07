//
//  CustomCell.swift
//  iapTest
//
//  Created by YooSeunghwan on 2017/12/04.
//  Copyright © 2017年 eys-style. All rights reserved.
//

import UIKit

class MyCustomCell: UITableViewCell {
    
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var tableLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setCell(_ title:String, _ descriptionStr:String, _ priceStr:String) {
        tableLabel.text = title
        descriptionLabel.text = descriptionStr
        buyBtn.setTitle(priceStr, for: .normal)
    }
    
}

