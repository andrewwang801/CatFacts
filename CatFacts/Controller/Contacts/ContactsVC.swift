//
//  ContactsVC.swift
//  CatFacts
//
//  Created by Pae on 12/29/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit
import SVProgressHUD

class ContactsVC: CFBaseVC, CreditItemSelectVCDelegate, ContactDetailVCDelegate {

    @IBOutlet weak var tblContacts: UITableView!
    var circularImage:UIImage? = nil
    var attributes:[String:AnyObject]? = nil
    var editBtn:UIBarButtonItem? = nil;
    //@IBOutlet weak var sideMenuButton:UIBarButtonItem!
    var isOrderChanged:Bool = false
    
    var arrContacts:NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let addItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(onClickAddContact))
        let editItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(toggleEditContacts))
        navigationItem.then {
            $0.rightBarButtonItems = [editItem, addItem]
            $0.leftBarButtonItem = nil
            $0.hidesBackButton = true
        }
        self.editBtn = editItem;
        initUI()
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "RevealMenu"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.then {
                $0.leftBarButtonItem = sideMenuButton
            }
            //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated);
        self.navigationItem.title = "Messages"
    }
    
    func onClickAddContact() {
        presentAddContractVC()
    }
    
    func changeOrderAndSave() {
        self.isOrderChanged = false
        var allObjects:[PFObject] = [];
        for(var i = 0; i < self.arrContacts?.count; i++) {
            let obj:PFObject = self.arrContacts![i] as! PFObject
            obj.setObject(NSNumber(integer: i), forKey: "order")
            allObjects.append(obj)
        }
        PFObject.saveAllInBackground(allObjects)
    }
    
    func toggleEditContacts() {
        if(self.tblContacts.editing && self.isOrderChanged) { //Save order of items
            self.changeOrderAndSave()
        }
        
        self.tblContacts.editing = !self.tblContacts.editing
        self.editBtn?.title = (self.tblContacts.editing) ? "Done" : "Edit"
    }
    
    func initUI() {
        if tblContacts != nil {
            tblContacts.estimatedRowHeight = 58
            tblContacts.rowHeight = UITableViewAutomaticDimension
        }
        arrContacts = NSMutableArray()
        
        self.loadContactsData()
    }
    
    func presentAddContractVC() {
        let addContractVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddContactVC");
        self.navigationItem.title = "";
        self.navigationController?.setViewControllers([self, addContractVC!], animated: true);
    }
    
    func didPurchaseCredit() {
        self.loadContactsData()
    }
    
    func presentCreditItemSelectVC(contactIndex:Int, activateAfterPurchase:Bool) {
        if let creditItemSelectVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreditItemSelectVC") as? CreditItemSelectVC {
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
        
        arrContacts!.removeAllObjects()
        
        CatFactsApi.reqMyContactList(nil) { (succeed, aArrResult) -> Void in
            if (succeed) {                
                self.arrContacts!.addObjectsFromArray(aArrResult! as [AnyObject])
                self.refreshList()
            }
        }
    }
    
    func loadTheContactData(rowIndex:Int) {
        
        guard let objectId = arrContacts![rowIndex].objectId else {return}
        CatFactsApi.reqTheContact(nil, objectId: objectId) { (succeed, aArrResult) -> Void in
            
            if (succeed) {
                self.arrContacts![rowIndex] = aArrResult![0]
                dispatch_async(dispatch_get_main_queue(), {
                    self.tblContacts.reloadRowsAtIndexPaths([NSIndexPath(forRow: rowIndex, inSection: 0)], withRowAnimation: .Fade)
                })
            }
        }
    }
    
    func refreshList() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tblContacts.reloadData()
            })

    }
    
    func deleteContactRow(rowIndex:NSInteger) -> Bool {
        
        if rowIndex >= 0 {
            
            CatFactsApi.reqDeleteContact(arrContacts![rowIndex] as! PFObject, viewController: nil, block: {[weak self] succeed, aArrResult in
                guard let s = self else {return}
                if succeed == true {
                    SVProgressHUD.showSuccessWithStatus("Contact deleted")
                    s.arrContacts!.removeObjectAtIndex(rowIndex)
                    
                    if s.arrContacts!.count > 0 {
                        s.changeOrderAndSave()
                        s.refreshList()
                    }
                    else {
                        let _addContactVC = s.storyboard?.instantiateViewControllerWithIdentifier("AddContactVC")
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
    
    func remoteReceiptValidation (receipt:NSData) {
        
        // Create the JSON object that describes the request
        let requestContents = ["receipt-data":receipt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]
        
        do {
            let requestData:NSData? = try NSJSONSerialization.dataWithJSONObject(requestContents, options: NSJSONWritingOptions.init(rawValue: 0))
            
            if requestData == nil {
                print("Receipt validating request data error.")
                return
            }
            
            print(requestData)
            
            // Create a POST request with the receipt data.
            let storeURL = NSURL(string: "https://buy.itunes.apple.com/verifyReceipt")
            let storeRequest = NSMutableURLRequest(URL: storeURL!)
            storeRequest.HTTPMethod = "POST"
            storeRequest.HTTPBody = requestData
            
            // Make a connection to the iTunes Store on a background queue.
            let queue = NSOperationQueue()
            NSURLConnection.sendAsynchronousRequest(storeRequest, queue: queue, completionHandler: { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Receipt validating connection error. \(connectionError?.localizedDescription)")
                }
                else {
                    do {
                        let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                        print("\(jsonResponse)")
                    }
                    catch {
                        print("Receipt validation : geting json response error")
                    }
                }
            })
        }
        catch {
            
        }
        
    }
    
    // MARK: ---Contact active state changed delegate---
    func onChangedActive(sender:AnyObject) {
        
        let sw = sender as! UISwitch
        let _cell = sw.superview!.superview! as! CFContactCell
        
        let indexPath = self.tblContacts.indexPathForCell(_cell)
        let rowIndex = indexPath!.row
        
        if rowIndex >= 0 {
            
            let objContact = arrContacts![rowIndex] as! PFObject
            let credit = objContact["numberCredits"] as? Int ?? 0
            
            if credit <= 0 && sw.on == true {
                
                self.presentCreditItemSelectVC(rowIndex, activateAfterPurchase: true)
                sw.setOn(!sw.on, animated: true)
                return
            }
            
            CatFactsApi.reqSetContactActive(arrContacts![rowIndex] as! PFObject, state: sw.on, viewController: nil, block: { (succeed, aArrResult) -> Void in
                if (succeed == false) {
                    sw.setOn(!sw.on, animated: true)
                }
            })
        }
    }
    
    
    func contactImageWithContactInformation(name:String) -> UIImage? {
        
        let width:CGFloat = 42
        let height:CGFloat = 42
        
        // Find the middle of the circle
        let center = CGPointMake(width/2.0, height/2.0)
        
        if (self.circularImage == nil) {
            
            var startAngle: Float = Float(2 * M_PI)
            var endAngle: Float = 0.0
            
            // Drawing code
            // Set the radius
            let strokeWidth = 0
            let radius = width/2.0
            
            let strokeColor = UIColor.lightGrayColor()
            let fillColor = UIColor.lightGrayColor()
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, UIScreen.mainScreen().scale)
            
            let context = UIGraphicsGetCurrentContext()
            
            // Set the stroke color
            CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
            
            // Set the line width
            CGContextSetLineWidth(context, CGFloat(strokeWidth))
            
            // Set the fill color (if you are filling the circle)
            CGContextSetFillColorWithColor(context, fillColor.CGColor)
            
            startAngle = startAngle - Float(M_PI_2)
            endAngle = endAngle - Float(M_PI_2)
            
            // Draw the arc around the circle
            CGContextAddArc(context, center.x, center.y, CGFloat(radius), CGFloat(startAngle), CGFloat(endAngle), 0)
            
            // Draw the arc
            CGContextDrawPath(context, .FillStroke)
            
            self.circularImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
        }
        
        var firstName = "", lastName = ""
        
        let array = name.characters.split(" ").map { String($0) }
        if array.count >= 2 {
            firstName = array[0]
            lastName = array[1]
        }
        else {
            firstName = name
            lastName = ""
        }
        
        let firstInitial = firstName.characters.count > 0 ? firstName.substringToIndex(firstName.startIndex.advancedBy(1)) : ""
        let lastInitial = lastName.characters.count > 0 ? lastName.substringToIndex(lastName.startIndex.advancedBy(1)) : ""
        let initials:NSString = (firstInitial + lastInitial).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.circularImage?.CGImage)
        
        if(self.attributes == nil) {
            let textColor = UIColor.whiteColor()
            let textFont = UIFont.systemFontOfSize(18)
            self.attributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : textFont]
        }
        let size = initials.sizeWithAttributes(self.attributes)
        initials.drawAtPoint(CGPointMake(center.x-size.width/2.0, center.y-size.height/2.0), withAttributes: self.attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension ContactsVC: UITableViewDataSource {
    
    //MARK:---Table View Delegates---
    func numberOfSectionsInTableView(tableView:UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return (arrContacts?.count)!
    }
    
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let _cellSet:CFContactCell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! CFContactCell
        let _objContact = arrContacts![indexPath.row] as! PFObject
        _cellSet.delegate = self
        let contactName:String = _objContact["name"] as? String ?? ""
        _cellSet.lbTitle.text = contactName
        _cellSet.lbDetail.text = "Credits"
        
        /*
        let userImageFile = userPhoto["imageFile"] as PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData!, error: NSError!) -> Void in
            if !error {
                let image = UIImage(data:imageData)
            }
        }*/
        
        let imageFile = _objContact["profilePicture"] as? PFFile
        
        if imageFile != nil {
            imageFile!.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    let image = UIImage(data: imageData!)
                    _cellSet.ivPhoto.image = image
                }
                else {
                    _cellSet.ivPhoto.image = self.contactImageWithContactInformation(contactName)
                }
            })
            
        }
        else {
            _cellSet.ivPhoto.image = self.contactImageWithContactInformation(contactName)
        }
        
        _cellSet.swState.on = _objContact["isActive"] as? Bool ?? false
        _cellSet.lbCredit.text = "\(_objContact["numberCredits"] as? Int ?? 0)"
        _cellSet.selectionStyle = .None
        
        return _cellSet
    }
}

extension ContactsVC: UITableViewDelegate {

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        self.isOrderChanged = true;
        let itemToMove = self.arrContacts![fromIndexPath.row]
        self.arrContacts!.removeObjectAtIndex(fromIndexPath.row)
        self.arrContacts!.insertObject(itemToMove, atIndex: toIndexPath.row)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {

            let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact? Any remaining credits will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
            let actionConfirm = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { ACTION in
                self.deleteContactRow(indexPath.row)
            }
            alertController.addAction(actionCancel)
            alertController.addAction(actionConfirm)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func dataUpdated() {
        self.refreshList()
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath newIndexPath:(NSIndexPath)) {
        
        let rowIndex = newIndexPath.row
        let _objContact = arrContacts![rowIndex]
        
        let contactDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContactDetailVC") as! ContactDetailVC
        contactDetailVC.contactObj = _objContact as? PFObject
        contactDetailVC.delegate = self
        self.navigationController?.pushViewController(contactDetailVC, animated: true);
        
        return;
        
        /*
        let numberPerDay = _objContact["numberFactsSentPerDay"] as? Int ?? 0
        
        let alertController = UIAlertController(title: "Messages Per Day", message: "How many messages are you going to send per day?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { ACTION in
            
        }
        let actionConfirm = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { ACTION in
            
            let newNumberPerDay = Int(alertController.textFields![0].text!)
            if newNumberPerDay <= 0 {
                SVProgressHUD.showInfoWithStatus("Only more than one messages available")
                return
            }
            else {
                CatFactsApi.reqSetContactNumberFactsSentPerDay(self.arrContacts![rowIndex] as! PFObject, numberFactsSentPerDay: newNumberPerDay!, viewController: nil, block: { (succeed, aArrResult) -> Void in
                    if (succeed == true) {
                        SVProgressHUD.showSuccessWithStatus("Saved successfully")
                    }
                    else {
                        SVProgressHUD.showErrorWithStatus("An error in saving the number")
                    }
                })
            }
        }
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionConfirm)
        alertController.addTextFieldWithConfigurationHandler({(txtField: UITextField!) in
            txtField.placeholder = "NumberPerDay"
            txtField.keyboardType = UIKeyboardType.NumberPad
            txtField.text = "\(numberPerDay)"
            txtField.selectAll(self)
        })
        presentViewController(alertController, animated: true, completion: nil)
        */
    }
}

extension ContactsVC: MGSwipeTableCellDelegate {
    
    // MARK:--Swipe Delegate--
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        swipeSettings.transition = .Border
        expansionSettings.buttonIndex = -1
        
        
        if direction == .LeftToRight  {
            
            let addButton = MGSwipeButton(title: "", icon: UIImage(named: "btn_SwipeAdd"), backgroundColor:kPrimaryColor, padding:0, callback:{ [weak self] (sender) -> Bool in
                
                guard let s = self else {return false}
                //[self weak]
                let indexPath = s.tblContacts.indexPathForCell(sender)
                self?.presentCreditItemSelectVC(indexPath!.row, activateAfterPurchase: false)
                return true
                })
            
            let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "btn_SwipeDelete"), backgroundColor: kPrimaryColor, padding: 0, callback: { [weak self] (sender) -> Bool in
                
                guard let s = self else {return false}
                
                let indexPath = s.tblContacts.indexPathForCell(sender)
                let rowIndex = indexPath!.row
                
                let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact? Any remaining credits will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
                let actionConfirm = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { ACTION in
                    s.deleteContactRow(rowIndex)
                }
                alertController.addAction(actionCancel)
                alertController.addAction(actionConfirm)
                self!.presentViewController(alertController, animated: true, completion: nil)
                return true
                })
            
            return [addButton, deleteButton]
        }
        else if  direction == .RightToLeft {
            
            let deleteBtn = MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor(), callback: {
                [weak self] (sender)-> Bool in
                
                guard let s = self else {return false}
                
                let indexPath = s.tblContacts.indexPathForCell(sender)
                let rowIndex = indexPath!.row
                
                let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact? Any remaining credits will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
                let actionConfirm = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { ACTION in
                    s.deleteContactRow(rowIndex)
                }
                alertController.addAction(actionCancel)
                alertController.addAction(actionConfirm)
                self!.presentViewController(alertController, animated: true, completion: nil)
                return true
                })

            return [deleteBtn]
        }
        
        return nil
    }
}