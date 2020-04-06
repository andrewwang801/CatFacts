//
//  TransferDialog.swift
//  CatFacts
//
//  Created by Apple Developer on 2020/3/28.
//  Copyright © 2020 Pae. All rights reserved.
//

import UIKit
import DropDown
import IBAnimatable

class TransferDialog: UIViewController {

    @IBOutlet weak var amountTextField: AnimatableTextField!
    @IBOutlet weak var recipientDropDown: AnimatableButton!
    @IBOutlet weak var recipientLabel: UILabel!
    
    var strRecipient = ""
    var currentObj: PFObject?
    var recipientObj: PFObject?
    
    enum ReturnCode {
        case left
        case right
    }
    
    var dismissHandler: ((ReturnCode) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadContactsList()
    }

    @IBAction func onDropDown(_ sender: Any) {
        dropDown.show()
    }
    
    @IBAction func onApply(_ sender: Any) {
        ///Validate
        if let nAmount = Int(amountTextField.text ?? ""), let _recipientObj = recipientObj, let _currentObj = currentObj,
            let currentCredits = _currentObj["numberCredits"] as? Int , nAmount <= currentCredits {

            let recipientCrdeits = _recipientObj["numberCredits"] as? Int ?? 0
            _currentObj["numberCredits"] = currentCredits - nAmount
            _recipientObj["numberCredits"] = recipientCrdeits + nAmount
            
            _currentObj.saveInBackground(block: { (succeeded, error) -> Void in
                SVProgressHUD.dismiss()
                if (succeeded == true) {
                    
                    ///Save recipient
                    _recipientObj.saveInBackground(block: { (succeeded, error) -> Void in
                        SVProgressHUD.dismiss()
                        if (succeeded == true) {
                            let currentName = _currentObj["name"] as? String ?? "";
                            let recipientName = _recipientObj["name"] as? String ?? "";
                            SVProgressHUD.setDefaultMaskType(.black)
                            SVProgressHUD.showInfo(withStatus: "\(nAmount) credits are transferred from \(currentName) to \(recipientName)")
                        }
                        else {
                            SVProgressHUD.showError(withStatus: "Failed to update data")
                        }
                    })
                }
                else {
                    SVProgressHUD.showError(withStatus: "Failed to update data")
                }
            })
            
            self.dismiss(animated: true) {
                self.dismissHandler?(.left)
            }
        }
        else {
            SVProgressHUD.showError(withStatus: "Please input correct data.")
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    ///DropDown
    let dropDown = DropDown()
    var arrContacts = NSMutableArray()
    func loadContactsList() {
        CatFactsApi.reqMyContactList(nil) { (succeed, aArrResult) -> Void in
            self.arrContacts.removeAllObjects()
            if (succeed) {
                self.arrContacts.addObjects(from: aArrResult! as [AnyObject])
                self.setupDropDown()
            }
        }
    }
    
    func setupDropDown() {
        dropDown.anchorView = recipientDropDown
        let dataSource: [String] = arrContacts.map( {
            let objContact = $0 as? PFObject
            if let _objContact = objContact, let _name = _objContact["name"] as? String {
                return _name
            }
            return ""
        })
        
        if let _currentObj = currentObj {
            dropDown.dataSource = dataSource.filter({$0 != _currentObj["name"] as! String})
        }
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.strRecipient = item
            self.recipientLabel.text = self.strRecipient
            for contact in self.arrContacts {
                let contactObj = contact as! PFObject
                if contactObj["name"] as! String == item {
                    self.recipientObj = contactObj
                }
            }
        }
    }
}
