//
//  CountryCodeCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/2/29.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown

class CountryCodeCell: DropDownCell {

    @IBOutlet var countryFlag: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
