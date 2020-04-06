//
//  CreditItemSelectVC.swift
//  CatFacts
//
//  Created by Pae on 1/21/16.
//  Copyright © 2016 Pae. All rights reserved.
//

import UIKit
//import SVProgressHUD

protocol CreditItemSelectVCDelegate: class {
    func didPurchaseCredit()
}

class CreditItemSelectVC: UITableViewController {

    var contactIndex = 0
    var theContact:PFObject?
    var activateAfterPurchase: Bool = false
    weak var delegate:CreditItemSelectVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated);
        self.navigationItem.title = "Purchase Credits"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Remove seperator inset
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) == true {
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) == true {
            cell.preservesSuperviewLayoutMargins = false
        }

        // Explictly set your cell's layout margins
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) == true {
            cell.layoutMargins = UIEdgeInsets.zero
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return kCreditPurchaseItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditItemIdentifier", for: indexPath)

        let creditItem = kCreditPurchaseItems[indexPath.row]
        
        // Configure the cell...
        cell.textLabel?.text = creditItem["name"] as? String
        cell.detailTextLabel?.text = creditItem["price"] as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Don't like to use storyboard segue.
        // Try Credit Purchase
        //guard let theContact = theContact else {return}
        let productId = kCreditPurchaseItems[indexPath.row]["productId"] as! String
        let _ = purchaseCreditForContact(productId)
    }
    
    // MARK:--In App Purchase--
    
    func findPurchaseItemWithProductId(_ productId:String)->[String:AnyObject]? {
        for index in 0 ..< kCreditPurchaseItems.count {
            let purchaseCredit = kCreditPurchaseItems[index]
            let _productId = purchaseCredit["productId"] as? String ?? ""
            if _productId == productId {
                return purchaseCredit as [String : AnyObject]
            }
        }
        return nil
    }
    
    func removeAllRemainingTransactions() {
        // take current payment queue
        let currentQueue = SKPaymentQueue.default()
        for transaction in currentQueue.transactions {
            currentQueue.finishTransaction(transaction)
        }
    }
    
    func purchaseCreditForContact(_ productId:String) -> Bool {
        
        SVProgressHUD.show(with: .gradient)
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success( _):
                
                guard
                    let receiptURL = Bundle.main.appStoreReceiptURL,
                    let receipt = try? Data(contentsOf: receiptURL),
                    let contact = self.theContact,
                    let contactId = contact.objectId else {
                        
                        SVProgressHUD.dismiss();
                        return
                }
                
                let receipt64BaseCodeString = receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
                //print(receipt64BaseCodeString)
                
                PFCloud.callFunction(inBackground: "validatePurchase", withParameters: ["receipt": receipt64BaseCodeString, "contactId":contactId]) {
                    (returnValue, error) in
                    if (error == nil) {
                        SVProgressHUD.dismiss();
                        SVProgressHUD.showSuccess(withStatus: "Buying an item completed successfully", maskType: .black)
                        
                        self.removeAllRemainingTransactions()
                        
                        if self.activateAfterPurchase == true {
                            
                            CatFactsApi.reqSetContactActive(contact, state: true, viewController: nil, block: { (succeed, aArrResult) -> Void in
                                if (succeed == false) {
                                    SVProgressHUD.showSuccess(withStatus: "Contact activated")
                                } else {
                                    SVProgressHUD.showError(withStatus: "Contact activation failed")
                                }
                                
                                contact.fetchIfNeededInBackground { (result, error) -> Void in
                                    self.delegate?.didPurchaseCredit()
                                }

                                let viewControllers = self.navigationController!.viewControllers
                                if viewControllers.count >= 2 {
                                    let previousVC = viewControllers[viewControllers.count-2]
                                    self.navigationController?.popViewController(animated: true)
                                    CommData.showAlert(fromView: previousVC, message: "Your messages will start being delivered in 15 minutes", withTitle: nil, action: nil)
                                }
                            })
                        }
                        else {
                            
                            contact.fetchIfNeededInBackground { (result, error) -> Void in
                                self.delegate?.didPurchaseCredit()
                            }

                            let viewControllers = self.navigationController!.viewControllers
                            if viewControllers.count >= 2 {
                                let previousVC = viewControllers[viewControllers.count-2]
                                self.navigationController?.popViewController(animated: true)
                                CommData.showAlert(fromView: previousVC, message: "Your messages will start being delivered in 15 minutes", withTitle: nil, action: nil)
                            }
                        }
                    }
                    else {
                        SVProgressHUD.dismiss();
                        
                        self.removeAllRemainingTransactions()
                        SVProgressHUD.showError(withStatus: "Buying an item failed", maskType: .black)
                    }
                }
                break
            case .error(_):
                SVProgressHUD.dismiss();
                SVProgressHUD.showError(withStatus: "Purchase failed", maskType: .black)
                break
            }
        }
        
        return true
    }
}
