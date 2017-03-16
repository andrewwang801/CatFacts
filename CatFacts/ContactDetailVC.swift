//
//  ContactDetailVC.swift
//  CatFacts
//
//  Created by Work on 16/04/2016.
//  Copyright © 2016 Pae. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ContactDetailVCDelegate: class {
    func dataUpdated()
    func didPurchaseCredit()
}

class ContactDetailVC: UIViewController, CreditItemSelectVCDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var contactObj:PFObject? = nil
    var editBtn:UIBarButtonItem? = nil;
    var cancelBtn:UIBarButtonItem? = nil;
    @IBOutlet weak var editContentView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactPhone: UILabel!
    @IBOutlet weak var buyMoreButton: UIButton!
    @IBOutlet weak var dropDownActionButton: UIButton!
    @IBOutlet weak var contactCredits: UILabel!
    @IBOutlet weak var editContactImageView: UIImageView!
    @IBOutlet weak var editContactNameField: UITextField!
    @IBOutlet weak var editContactPhoneField: UITextField!
    let imagePicker = UIImagePickerController()
    var imageChanged:Bool = false
    weak var delegate:ContactDetailVCDelegate?
    let dropDownView = DropDown()
    var numberOfMessagesPerDay:Int = 1
    
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let fixOrientationImage = image.fixOrientation()
        let resizedImage = fixOrientationImage.resizeForProfileSize(CGSizeMake(200, 200))
        
        self.editContactImageView.image = resizedImage
        self.editBtn!.enabled = true
        
        self.imageChanged = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: TextField
    
    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        if let nextField: UITextField = self.view.viewWithTag(nextTag) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        self.editBtn!.enabled = true
        
        if textField == self.editContactPhoneField {
            return matchPhoneNumberInTextField(textField, changedLength: range.length)
        }
        else if textField == self.editContactNameField {
            /*
            let start = textField.text!.startIndex.advancedBy(range.location)
            let end   = start.advancedBy(range.length)
            let swiftRange  = Range<String.Index>(start: start, end: end)
            let inputString = textField.text!.stringByReplacingCharactersInRange(swiftRange, withString: string)
            
            //Capitalize First letter
            if(inputString.characters.count > 0) {
                let str = (inputString as NSString).substringWithRange(NSMakeRange(0, 1)).uppercaseString
                textField.text = (inputString as NSString).stringByReplacingCharactersInRange(NSMakeRange(0, 1), withString:str)
            }
            
            return false
            */
        }
//        else if textField == self.editContactMessageLimitField {
//            let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
//            return string.rangeOfCharacterFromSet(invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
//        }
        
        return true
    }
    
    func matchPhoneNumberInTextField(textField: UITextField, changedLength: Int) -> Bool {
        
        let length = getLength(textField.text!)
        
        if length == 10 {
            if changedLength == 0 {
                return false;
            }
        }
        
        if length == 3 {
            let num = formatNumber(textField.text!)
            textField.text = "(\(num)) "
            
            if changedLength > 0 {
                textField.text = "\((num as NSString).substringToIndex(3))"
            }
        }
        else if length == 6 {
            let num = formatNumber(textField.text!)
            textField.text = "(\((num as NSString).substringToIndex(3))) \((num as NSString).substringFromIndex(3))-"
            
            if changedLength > 0 {
                textField.text = "(\((num as NSString).substringToIndex(3))) \((num as NSString).substringFromIndex(3))"
            }
        }
        else if length == 10 {
            let num = formatNumber(textField.text!)
            
            if changedLength > 0 {
                textField.text = "(\((num as NSString).substringToIndex(3))) \((num as NSString).substringWithRange(NSRange.init(location: 3,length: 3)))-\((num as NSString).substringFromIndex(6))"
            }
        }
        
        return true;
    }
    
    func formatNumber(mobNumber:String) -> String {
        
        var mobileNumber = mobNumber;
        
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("(", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(")", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("-", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("+", withString: "")
        
        let length = mobileNumber.characters.count
        
        if length > 10 {
            mobileNumber = (mobileNumber as NSString).substringFromIndex(length-10)
        }
        
        return mobileNumber;
    }
    
    func getLength(mobNumber:String) -> Int {
        
        var mobileNumber = mobNumber;
        
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("(", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(")", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("-", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("+", withString: "")
        
        let length = mobileNumber.characters.count
        
        return length;
    }
    
    // MARK: - Class methods
    
    func toggleEditContacts() {
        
        if self.contactObj == nil {
            return
        }
        
        if self.contentView.hidden == false {
            
            self.editContactImageView.image = self.contactImageView.image
            self.editContactNameField.text = self.contactName.text
            self.editContactPhoneField.text = self.contactPhone.text
            
            navigationItem.then {
                $0.leftBarButtonItem = self.cancelBtn
            }
            self.editBtn?.title = "Done"
            self.editBtn?.enabled = false
            self.editContentView.hidden = false
            self.contentView.hidden = true
        }
        else {
            //save new settings
            self.saveSettings()
            //self.endEditing()
        }
    }
    
    func validatePhoneNumber(phoneNumber:String) -> Bool {
        return phoneNumber.characters.count > 0
    }
    
    func validateName(name:String) -> Bool {
        return name.characters.count > 0
    }
    
    func validateMessageCount(messageCount:String) -> Bool {
        return messageCount.characters.count > 0
    }
    
    func saveSettings() {
        
        var eb = self.validatePhoneNumber(self.editContactPhoneField.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct phone number.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        eb = self.validateName(self.editContactNameField.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct name.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
//        eb = self.validateMessageCount(self.editContactMessageLimitField.text!)
//        if (eb == false) {
//            let alert = UIAlertController(title: "Sorry", message: "Please enter correct message count.", preferredStyle: .Alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//            alert.addAction(defaultAction)
//            self.presentViewController(alert, animated: true, completion: nil)
//            return
//        }
//        
//        let numberPerDay:Int = Int(self.editContactMessageLimitField.text!) ?? 0
//        if numberPerDay <= 0 {
//            SVProgressHUD.showInfoWithStatus("Only more than one messages available")
//            return
//        }
        
        SVProgressHUD.showWithMaskType(.Black)
        
        if let contactData = self.contactObj {
            contactData["name"] = self.editContactNameField.text!
            contactData["phoneNumber"] = self.editContactPhoneField.text!
            //contactData["numberFactsSentPerDay"] = numberPerDay
            
            if self.imageChanged && self.editContactImageView.image != nil {
                let image = self.editContactImageView.image!
                let imageData:NSData = UIImageJPEGRepresentation(image, 1.0)!
                let file = PFFile(name: "profilePicture.jpg", data: imageData)
                contactData["profilePicture"] = file
            }
            
            contactData.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                SVProgressHUD.dismiss()
                if (succeeded == true) {
                    SVProgressHUD.showInfoWithStatus("Changes saved.", maskType: .Black)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loadContactData()
                        self.endEditing()
                        self.delegate?.dataUpdated()
                    })
                }
                else {
                    SVProgressHUD.showErrorWithStatus("Failed to update data", maskType: .Black)
                }
            })
        }
    }
    
    @IBAction func changePhoto() {
        
        self.imagePicker.delegate = self
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Picture", preferredStyle: .ActionSheet)
        
        let cameraRollAction = UIAlertAction(title: "From Camera Roll", style: .Default) { (alert) in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePictureAction = UIAlertAction(title: "Take Picture", style: .Default) { (alert) in
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) in
        }
        
        optionMenu.addAction(cameraRollAction)
        optionMenu.addAction(takePictureAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func resignAllFirstResponders() {
        
        self.editContactNameField.resignFirstResponder()
        self.editContactPhoneField.resignFirstResponder()
        //self.editContactMessageLimitField.resignFirstResponder()
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        
        self.resignAllFirstResponders()
    }
    
    func endEditing() {

        self.resignAllFirstResponders()
        
        navigationItem.then {
            $0.leftBarButtonItem = nil
        }
        self.editBtn?.title = "Edit"
        self.editBtn?.enabled = true
        self.editContentView.hidden = true
        self.contentView.hidden = false
    }
    
    func contactImageWithContactInformation(name:String) -> UIImage? {
        
        let width:CGFloat = 42
        let height:CGFloat = 42
        
        // Find the middle of the circle
        let center = CGPointMake(width/2.0, height/2.0)
        
        var startAngle: Float = Float(2 * M_PI)
        var endAngle: Float = 0.0
        
        // Drawing code
        // Set the radius
        let strokeWidth = 0
        let radius = width/2.0
        
        let strokeColor = UIColor.lightGrayColor()
        let fillColor = UIColor.lightGrayColor()
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, UIScreen.mainScreen().scale)
        
        var context = UIGraphicsGetCurrentContext()
        
        // Set the stroke color
        CGContextSetStrokeColorWithColor(context!, strokeColor.CGColor)
        
        // Set the line width
        CGContextSetLineWidth(context!, CGFloat(strokeWidth))
        
        // Set the fill color (if you are filling the circle)
        CGContextSetFillColorWithColor(context!, fillColor.CGColor)
        
        startAngle = startAngle - Float(M_PI_2)
        endAngle = endAngle - Float(M_PI_2)
        
        // Draw the arc around the circle
        CGContextAddArc(context!, center.x, center.y, CGFloat(radius), CGFloat(startAngle), CGFloat(endAngle), 0)
        
        // Draw the arc
        CGContextDrawPath(context!, .FillStroke)
        
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
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
        context = UIGraphicsGetCurrentContext()
        
        CGContextDrawImage(context!, CGRectMake(0, 0, width, height), (circularImage?.CGImage)!)
        
        let textColor = UIColor.whiteColor()
        let textFont = UIFont.systemFontOfSize(20)
        let attributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : textFont]
        let size = initials.sizeWithAttributes(attributes)
        initials.drawAtPoint(CGPointMake(center.x-size.width/2.0, center.y-size.height/2.0), withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }

    func didPurchaseCredit() {
        
        self.delegate?.didPurchaseCredit()
        
        //SVProgressHUD.show()
        self.contactObj?.fetchInBackgroundWithBlock({ (object, error) in
            //SVProgressHUD.dismiss()
            if error == nil {
                self.contactObj = object
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadContactData()
                })
            }
        })
    }
    
    @IBAction func presentCreditItemSelectVC() {
        
        if let contactData = self.contactObj {
            
            //let credit = contactData["numberCredits"] as? Int ?? 0
            
            if let creditItemSelectVC =  self.storyboard?.instantiateViewControllerWithIdentifier("CreditItemSelectVC") as? CreditItemSelectVC {
                self.navigationItem.title = "";
                creditItemSelectVC.theContact = contactData
                creditItemSelectVC.activateAfterPurchase = false
                creditItemSelectVC.delegate = self
                self.navigationController?.pushViewController(creditItemSelectVC, animated: true)
            }
        }
    }
    
    func loadContactData() {
        
        if let contactData = self.contactObj {
            
            let contactName:String = contactData["name"] as? String ?? ""
            self.contactName.text = contactName
            
            let phoneNumber:String = contactData["phoneNumber"] as? String ?? ""
            self.contactPhone.text = phoneNumber
            
            let imageFile = contactData["profilePicture"] as? PFFile
            if imageFile != nil {
                imageFile!.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        let image = UIImage(data: imageData!)
                        self.contactImageView.image = image
                    }                        
                    else {
                        self.contactImageView.image = self.contactImageWithContactInformation(contactName)
                    }
                })
            }
            else {
                self.contactImageView.image = self.contactImageWithContactInformation(contactName)
            }
            
            self.numberOfMessagesPerDay = contactData["numberFactsSentPerDay"] as? Int ?? 1
            self.dropDownActionButton.setTitle("\(self.numberOfMessagesPerDay)", forState: .Normal)

            self.contactCredits.text = "\(contactData["numberCredits"] as? Int ?? 0)"
        }
    }
    
    func saveNumberOfMessagesPerDayToParse() {

        SVProgressHUD.showWithMaskType(.Black)
        
        let numberPerDay:Int = self.numberOfMessagesPerDay
        
        if let contactData = self.contactObj {
            contactData["numberFactsSentPerDay"] = numberPerDay
            contactData.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                SVProgressHUD.dismiss()
                if (succeeded == true) {
                    SVProgressHUD.showInfoWithStatus("Changes saved.", maskType: .Black)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dropDownActionButton.setTitle("\(self.numberOfMessagesPerDay)", forState: .Normal)
                        //self.loadContactData()
                        //self.endEditing()
                        self.delegate?.dataUpdated()
                    })
                }
                else {
                    SVProgressHUD.showErrorWithStatus("Failed to update data", maskType: .Black)
                }
            })
        }
    }
    
    func addUnderlineToTextField(txtField:UITextField) {
        let border = CALayer()
        let width = 1.0/UIScreen.mainScreen().scale
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: txtField.frame.size.height - width, width:  txtField.frame.size.width, height: txtField.frame.size.height)
        border.borderWidth = width
        txtField.layer.addSublayer(border)
        txtField.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.addUnderlineToTextField(self.editContactPhoneField)
        self.addUnderlineToTextField(self.editContactNameField)

    }
    
    @IBAction func showDropDown() {
        if self.dropDownView.hidden == false {
            self.dropDownView.hide()
        }
        else {
            self.dropDownView.reloadAllComponents()
            self.dropDownView.selectRowAtIndex(self.numberOfMessagesPerDay-1)
            self.dropDownView.show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.performSelector(#selector(didPurchaseCredit), withObject: nil, afterDelay: 5)
        
        self.navigationItem.title = "Contact Detail"
        
        self.editBtn = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(toggleEditContacts))
        self.cancelBtn =  UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(endEditing))
        navigationItem.then {
            $0.rightBarButtonItem = self.editBtn
        }
        self.editContentView.hidden = true
        self.contentView.hidden = false
        
        self.loadContactData()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.editContentView.addGestureRecognizer(gestureRecognizer)
        
        self.buyMoreButton.layer.cornerRadius = 5.0;
        
        self.dropDownView.anchorView = self.dropDownActionButton
        self.dropDownView.direction = .Bottom
        self.dropDownView.bottomOffset = CGPoint(x: 0, y:self.dropDownView.anchorView!.bounds.height)
        self.dropDownView.dismissMode = .Automatic
        
        self.dropDownView.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        
        self.dropDownView.selectionAction = {(index, item) in
            print("item \(item) at index \(index) selected.")
            self.numberOfMessagesPerDay = index+1
            self.saveNumberOfMessagesPerDayToParse()
        }
        
    }
    
    

}
