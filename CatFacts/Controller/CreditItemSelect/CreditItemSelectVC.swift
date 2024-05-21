//
//  CreditItemSelectVC.swift
//  CatFacts
//
//  Created by Pae on 1/21/16.
//  Copyright © 2016 Pae. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CreditItemSelectVCDelegate: class {
    func didPurchaseCredit()
}

class CreditItemSelectVC: UITableViewController {

    var contactIndex = 0
    var theContact:PFObject?
    var activateAfterPurchase:Bool = false
    weak var delegate:CreditItemSelectVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated);
        self.navigationItem.title = "Purchase Credits"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Remove seperator inset
        if cell.respondsToSelector("setSeparatorInset:") == true {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") == true {
            cell.preservesSuperviewLayoutMargins = false
        }

        // Explictly set your cell's layout margins
        if cell.respondsToSelector("setLayoutMargins:") == true {
            cell.layoutMargins = UIEdgeInsetsZero
        }

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return kCreditPurchaseItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CreditItemIdentifier", forIndexPath: indexPath)

        let creditItem = kCreditPurchaseItems[indexPath.row]
        
        // Configure the cell...
        cell.textLabel?.text = creditItem["name"] as? String
        cell.detailTextLabel?.text = creditItem["price"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Don't like to use storyboard segue.
        // Try Credit Purchase
        //guard let theContact = theContact else {return}
        let productId = kCreditPurchaseItems[indexPath.row]["productId"] as! String
        purchaseCreditForContact(productId)
    }
    
    // MARK:--In App Purchase--
    
    func findPurchaseItemWithProductId(productId:String)->[String:AnyObject]? {
        for var index = 0; index < kCreditPurchaseItems.count; index++ {
            let purchaseCredit = kCreditPurchaseItems[index]
            if purchaseCredit["productId"] == productId {
                return purchaseCredit
            }
        }
        return nil
    }
    
    func removeAllRemainingTransactions() {
        // take current payment queue
        let currentQueue = SKPaymentQueue.defaultQueue()
        for transaction in currentQueue.transactions {
            currentQueue.finishTransaction(transaction)
        }
    }
    
    func purchaseCreditForContact(productId:String) -> Bool {
        
        SVProgressHUD.showWithMaskType(.Gradient)
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .Success( _):
                
                guard
                    let receiptURL = NSBundle.mainBundle().appStoreReceiptURL,
                    let receipt = NSData(contentsOfURL: receiptURL),
                    let contact = self.theContact,
                    let contactId = contact.objectId else {
                        
                        SVProgressHUD.dismiss();
                        return
                }
                
                let receipt64BaseCodeString = receipt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
                //print(receipt64BaseCodeString)
                
                PFCloud.callFunctionInBackground("validatePurchase", withParameters: ["receipt": receipt64BaseCodeString, "contactId":contactId]) {
                    (returnValue, error) in
                    if (error == nil) {
                        SVProgressHUD.dismiss();
                        SVProgressHUD.showSuccessWithStatus("Buying an item completed successfully", maskType: .Black)
                        
                        self.removeAllRemainingTransactions()
                        
                        if self.activateAfterPurchase == true {
                            
                            CatFactsApi.reqSetContactActive(contact, state: true, viewController: nil, block: { (succeed, aArrResult) -> Void in
                                if (succeed == false) {
                                    SVProgressHUD.showSuccessWithStatus("Contact activated")
                                } else {
                                    SVProgressHUD.showErrorWithStatus("Contact activation failed")
                                }
                                
                                contact.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                                    self.delegate?.didPurchaseCredit()
                                }
                                
                                if let contactsVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsVC") {
                                    //self.navigationController?.setViewControllers([contactsVC], animated: true)
                                    self.navigationController?.popViewControllerAnimated(true)
                                    CommData.showAlertFromView(contactsVC, message: "Your messages will start being delivered in 15 minutes", withTitle: nil, action: nil)
                                }
                            })
                        }
                        else {
                            
                            contact.fetchIfNeededInBackgroundWithBlock { (result, error) -> Void in
                                self.delegate?.didPurchaseCredit()
                            }
                            
                            if let contactsVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsVC") {
                                //self.navigationController?.setViewControllers([contactsVC], animated: true)
                                self.navigationController?.popViewControllerAnimated(true)
                                CommData.showAlertFromView(contactsVC, message: "Your messages will start being delivered in 15 minutes", withTitle: nil, action: nil)
                            }
                        }
                    }
                    else {
                        SVProgressHUD.dismiss();
                        
                        self.removeAllRemainingTransactions()
                        SVProgressHUD.showErrorWithStatus("Buying an item failed", maskType: .Black)
                    }
                }
                break
            case .Error(_):
                SVProgressHUD.dismiss();
                SVProgressHUD.showErrorWithStatus("Purchase failed", maskType: .Black)
                break
            }
        }
        
        return true
    }
}
