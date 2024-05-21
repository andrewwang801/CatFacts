//
//  CFContactCell.swift
//  CatFacts
//
//  Created by Pae on 12/29/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit

class CFContactCell: MGSwipeTableCell {

    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDetail: UILabel!
    @IBOutlet weak var lbCredit: PAInsetLabel!
    @IBOutlet weak var swState: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        swState.tintColor = UIColor(red: 236/255.0, green: 145/255.0, blue: 118/255.0, alpha: 1.0)
        swState.layer.cornerRadius = swState.layer.bounds.size.height/2.0;
        swState.backgroundColor = UIColor(red: 236/255.0, green: 145/255.0, blue: 118/255.0, alpha: 1.0)
        
        lbCredit.edgeInsets =  UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3);
        
        lbCredit.setCornerRadius(5.0, borderWidth: 0.0, borderColor: lbCredit.backgroundColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
