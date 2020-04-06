//
//  ContactsVC.swift
//  CatFacts
//
//  Created by Pae on 12/29/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit
//import SVProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ContactsVC: CFBaseVC, CreditItemSelectVCDelegate, ContactDetailVCDelegate {

    @IBOutlet weak var tblContacts: UITableView!

    var circularImage:UIImage? = nil
    var attributes:[NSAttributedString.Key:Any]? = nil
    var editBtn:UIBarButtonItem? = nil;
    //@IBOutlet weak var sideMenuButton:UIBarButtonItem!
    var isOrderChanged:Bool = false
    
    var arrContacts:NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onClickAddContact))
        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditContacts))
        navigationItem.rightBarButtonItems = [editItem, addItem]
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        self.editBtn = editItem;
        initUI()
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "RevealMenu"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
            //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated);
        self.navigationItem.title = "Messages"

        self.loadContactsData()
    }
    
    @objc func onClickAddContact() {
        presentAddContractVC()
    }
    
    func changeOrderAndSave() {
        self.isOrderChanged = false
        var allObjects:[PFObject] = [];

        for i in 0..<(self.arrContacts?.count ?? 0) {
            let obj = self.arrContacts![i] as! PFObject
            obj.setObject(NSNumber(value: i as Int), forKey: "order")
            allObjects.append(obj)
        }
        PFObject.saveAll(inBackground: allObjects)
    }
    
    @objc func toggleEditContacts() {

        if(self.tblContacts.isEditing && self.isOrderChanged) { //Save order of items
            self.changeOrderAndSave()
        }
        
        self.tblContacts.isEditing = !self.tblContacts.isEditing
        self.editBtn?.title = (self.tblContacts.isEditing) ? "Done" : "Edit"
    }
    
    func initUI() {
        if tblContacts != nil {
            tblContacts.estimatedRowHeight = 58
            tblContacts.rowHeight = UITableView.automaticDimension
        }
        arrContacts = NSMutableArray()
    }
    
    func presentAddContractVC() {
        let addContractVC = self.storyboard?.instantiateViewController(withIdentifier: "AddContactVC");
        self.navigationItem.title = "";
        self.navigationController?.setViewControllers([self, addContractVC!], animated: true);
    }
    
    func didPurchaseCredit() {
        self.loadContactsData()
    }
    
    func presentCreditItemSelectVC(_ contactIndex:Int, activateAfterPurchase:Bool) {
        if let creditItemSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "CreditItemSelectVC") as? CreditItemSelectVC {
            self.navigationItem.title = "";
            creditItemSelectVC.theContact = arrContacts![contactIndex] as? PFObject
            creditItemSelectVC.activateAfterPurchase = activateAfterPurchase
            creditItemSelectVC.delegate = self
            //self.navigationController?.setViewControllers([self, creditItemSelectVC], animated: true);
            self.navigationController?.pushViewController(creditItemSelectVC, animated: true)
        }
    }
    
    //PRAGMA MARK: - Load data
    func loadContactsData() {
        
        CatFactsApi.reqMyContactList(nil) { (succeed, aArrResult) -> Void in
            self.arrContacts!.removeAllObjects()
            if (succeed) {
                self.arrContacts!.addObjects(from: aArrResult! as [AnyObject])
                self.refreshList()
            }
        }
    }
    
    func loadTheContactData(_ rowIndex:Int) {
        
        guard let objectId = (arrContacts![rowIndex] as AnyObject).objectId else {return}
        CatFactsApi.reqTheContact(nil, objectId: objectId) { (succeed, aArrResult) -> Void in
            
            if (succeed) {
                self.arrContacts![rowIndex] = aArrResult![0]
                DispatchQueue.main.async(execute: {
                    self.tblContacts.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .fade)
                })
            }
        }
    }
    
    func refreshList() {
        DispatchQueue.main.async(execute: {
            self.tblContacts.reloadData()
            })

    }
    
    func deleteContactRow(_ rowIndex:NSInteger) -> Bool {
        
        if rowIndex >= 0 {
            
            CatFactsApi.reqDeleteContact(arrContacts![rowIndex] as! PFObject, viewController: nil, block: {[weak self] succeed, aArrResult in
                guard let s = self else {return}
                if succeed == true {
                    SVProgressHUD.showSuccess(withStatus: "Contact deleted")
                    s.arrContacts!.removeObject(at: rowIndex)
                    
                    if s.arrContacts!.count > 0 {
                        s.changeOrderAndSave()
                        s.refreshList()
                    }
                    else {
                        let _addContactVC = s.storyboard?.instantiateViewController(withIdentifier: "AddContactVC")
                        s.navigationController?.setViewControllers([_addContactVC!], animated: true)
                    }
                }
            })
            return true
        }
        else {
            return false
        }
    }
    
    func remoteReceiptValidation (_ receipt:Data) {
        
        // Create the JSON object that describes the request
        let requestContents = ["receipt-data":receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))]
        
        do {
            let requestData:Data? = try JSONSerialization.data(withJSONObject: requestContents, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            
            if requestData == nil {
                NSLog("Receipt validating request data error.")
                return
            }

            NSLog("\(requestData!)")
            
            // Create a POST request with the receipt data.
            let storeURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")
            let storeRequest = NSMutableURLRequest(url: storeURL!)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            
            // Make a connection to the iTunes Store on a background queue.
            let queue = OperationQueue()
            NSURLConnection.sendAsynchronousRequest(storeRequest as URLRequest, queue: queue, completionHandler: { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    NSLog("Receipt validating connection error. \(connectionError!.localizedDescription)")
                }
                else {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                        NSLog("\(jsonResponse)")
                    }
                    catch {
                        NSLog("Receipt validation : geting json response error")
                    }
                }
            })
        }
        catch {
            
        }
        
    }
    
    // MARK: ---Contact active state changed delegate---
    @IBAction func onChangedActive(_ sender: Any) {
        
        let sw = sender as! UISwitch
        let _cell = sw.superview!.superview! as! CFContactCell
        
        let indexPath = self.tblContacts.indexPath(for: _cell)
        let rowIndex = indexPath!.row
        
        if rowIndex >= 0 {
            
            let objContact = arrContacts![rowIndex] as! PFObject
            let credit = objContact["numberCredits"] as? Int ?? 0
            
            if credit <= 0 && sw.isOn == true {
                
                self.presentCreditItemSelectVC(rowIndex, activateAfterPurchase: true)
                sw.setOn(!sw.isOn, animated: true)
                return
            }
            
            CatFactsApi.reqSetContactActive(arrContacts![rowIndex] as! PFObject, state: sw.isOn, viewController: nil, block: { (succeed, aArrResult) -> Void in
                if (succeed == false) {
                    sw.setOn(!sw.isOn, animated: true)
                }
            })
        }
    }
    
    func contactImageWithContactInformation(_ name:String) -> UIImage? {
        
        let width:CGFloat = 42
        let height:CGFloat = 42
        
        // Find the middle of the circle
        let center = CGPoint(x: width/2.0, y: height/2.0)
        
        if (self.circularImage == nil) {

            // Drawing code
            // Set the radius
            let strokeWidth = 0

            let strokeColor = UIColor.lightGray
            let fillColor = UIColor.lightGray
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
            
            let context = UIGraphicsGetCurrentContext()

            // Set the stroke color
            context!.setStrokeColor(strokeColor.cgColor)
            
            // Set the line width
            context!.setLineWidth(CGFloat(strokeWidth))
            
            // Set the fill color (if you are filling the circle)
            context!.setFillColor(fillColor.cgColor)

            context!.fillEllipse(in: CGRect(x: 0, y: 0, width: width, height: height))
            
            self.circularImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
        }
        
        var firstName = "", lastName = ""
        
        let array = name.split(separator: " ").map { String($0) }
        if array.count >= 2 {
            firstName = array[0]
            lastName = array[1]
        }
        else {
            firstName = name
            lastName = ""
        }
        
        let firstInitial = firstName.count > 0 ? firstName.substring(to: firstName.index(firstName.startIndex, offsetBy: 1)) : ""
        let lastInitial = lastName.count > 0 ? lastName.substring(to: lastName.index(lastName.startIndex, offsetBy: 1)) : ""
        let initials = (firstInitial + lastInitial).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        context!.draw((self.circularImage?.cgImage)!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        if(self.attributes == nil) {
            let textColor = UIColor.white
            let textFont = UIFont.systemFont(ofSize: 18)
            self.attributes = [NSAttributedString.Key.foregroundColor : textColor, NSAttributedString.Key.font : textFont]
        }
        let size = initials.size(withAttributes: self.attributes)
        initials.draw(at: CGPoint(x: center.x-size.width/2.0, y: center.y-size.height/2.0), withAttributes: self.attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension ContactsVC: UITableViewDataSource {
    
    //MARK:---Table View Delegates---
    func numberOfSections(in tableView:UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return (arrContacts?.count)!
    }
    
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        let _cellSet:CFContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! CFContactCell
        let _objContact = arrContacts![indexPath.row] as! PFObject
        _cellSet.delegate = self
        let contactName:String = _objContact["name"] as? String ?? ""
        _cellSet.lbTitle.text = contactName
        _cellSet.lbDetail.text = "Credits"
        
        let imageFile = _objContact["profilePicture"] as? PFFile
        
        if imageFile != nil {

            imageFile!.getDataInBackground { (imageData, error) in
                if error == nil {
                    let image = UIImage(data: imageData!)
                    _cellSet.ivPhoto.image = image
                }
                else {
                    _cellSet.ivPhoto.image = self.contactImageWithContactInformation(contactName)
                }
            }
        }
        else {
            _cellSet.ivPhoto.image = self.contactImageWithContactInformation(contactName)
        }
        
        _cellSet.swState.isOn = _objContact["isActive"] as? Bool ?? false
        _cellSet.lbCredit.text = "\(_objContact["numberCredits"] as? Int ?? 0)"
        _cellSet.selectionStyle = .none
        
        return _cellSet
    }
}

extension ContactsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        self.isOrderChanged = true;
        let itemToMove = self.arrContacts![fromIndexPath.row]
        self.arrContacts!.removeObject(at: fromIndexPath.row)
        self.arrContacts!.insert(itemToMove, at: toIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {

            let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact? Any remaining credits will be lost.", preferredStyle: UIAlertController.Style.alert)
            
            let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:nil)
            let actionConfirm = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default) { action in
                let _  = self.deleteContactRow(indexPath.row)
            }
            alertController.addAction(actionCancel)
            alertController.addAction(actionConfirm)
            self.present(alertController, animated: true, completion: nil)
            
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func dataUpdated() {
        self.refreshList()
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt newIndexPath:IndexPath) {
        
        let rowIndex = newIndexPath.row
        let _objContact = arrContacts![rowIndex]

        let contactDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailVC") as! ContactDetailVC
        contactDetailVC.contactObj = _objContact as? PFObject
        contactDetailVC.delegate = self
        self.navigationItem.title = "";
        self.navigationController?.pushViewController(contactDetailVC, animated: true);
        
        return;
    }
}

extension ContactsVC: MGSwipeTableCellDelegate {
    
    // MARK:--Swipe Delegate--
    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }

    func swipeTableCell(_ cell: MGSwipeTableCell!, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [Any]! {

        swipeSettings.transition = .border
        expansionSettings.buttonIndex = -1

        if direction == .leftToRight  {

            let addButton = MGSwipeButton(title: "", icon: UIImage(named: "btn_SwipeAdd"), backgroundColor:kPrimaryColor, padding:0, callback:{ [weak self] (sender) -> Bool in

                guard let s = self else {return false}
                //[self weak]
                let indexPath = s.tblContacts.indexPath(for: sender!)
                self?.presentCreditItemSelectVC(indexPath!.row, activateAfterPurchase: false)
                return true
            })

            let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "btn_SwipeDelete"), backgroundColor: kPrimaryColor, padding: 0, callback: { [weak self] (sender) -> Bool in

                guard let s = self else {return false}

                let indexPath = s.tblContacts.indexPath(for: sender!)
                let rowIndex = indexPath!.row

                let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact? Any remaining credits will be lost.", preferredStyle: UIAlertController.Style.alert)

                let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:nil)
                let actionConfirm = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default) { ACTION in
                    let _ = s.deleteContactRow(rowIndex)
                }
                alertController.addAction(actionCancel)
                alertController.addAction(actionConfirm)
                self!.present(alertController, animated: true, completion: nil)
                return true
            })

            return [addButton!, deleteButton!]
        }
        else if direction == .rightToLeft {

            let deleteBtn = MGSwipeButton(title: "Delete", backgroundColor: UIColor.red, callback: {
                [weak self] (sender)-> Bool in

                guard let s = self else {return false}

                let indexPath = s.tblContacts.indexPath(for: sender!)
                let rowIndex = indexPath!.row

                let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact? Any remaining credits will be lost.", preferredStyle: UIAlertController.Style.alert)

                let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:nil)
                let actionConfirm = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default) { ACTION in
                    let _ = s.deleteContactRow(rowIndex)
                }
                alertController.addAction(actionCancel)
                alertController.addAction(actionConfirm)
                self!.present(alertController, animated: true, completion: nil)
                return true
            })

            return [deleteBtn!]
        }

        return nil
    }

}
