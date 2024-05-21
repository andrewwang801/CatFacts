//
//  Constants.swift
//  CatFacts
//
//  Created by Pae on 1/17/16.
//  Copyright © 2016 Pae. All rights reserved.
//

import Foundation

extension UIColor {
    
    convenience init(hex: Int) {
        
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}

let AppStoreLink = "itms-apps://itunes.apple.com/app/id1074493881?mt=8"

let kPrimaryColor = UIColor(hex: 0x3F9DD9)
let kDeviceIsIPAD = UIDevice.currentDevice().userInterfaceIdiom == .Pad

let kCreditPurchaseItems =
    [["name":"Credit Pack +10", "desc":"You could increase the credits by 10 for $0.99", "productId":"com.mjm.catfacts.creditpack10", "increaseCredit":10, "price":"$0.99"],
    ["name":"Credit Pack +20", "desc":"You could increase the credits by 20 for $1.99", "productId":"com.mjm.catfacts.creditpack20", "increaseCredit":20, "price":"$1.99"],
    ["name":"Credit Pack +30", "desc":"You could increase the credits by 30 for $2.99", "productId":"com.mjm.catfacts.creditpack30", "increaseCredit":30, "price":"$2.99"],
    ["name":"Credit Pack +40", "desc":"You could increase the credits by 40 for $3.99", "productId":"com.mjm.catfacts.creditpack40", "increaseCredit":40, "price":"$3.99"],
    ["name":"Credit Pack +50", "desc":"You could increase the credits by 50 for $4.99", "productId":"com.mjm.catfacts.creditpack50", "increaseCredit":50, "price":"$4.99"]]
