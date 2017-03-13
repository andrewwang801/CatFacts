//
//  AddContactVC.swift
//  CatFacts
//
//  Created by Pae on 12/29/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddContactVC: CFBaseVC {

    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var lbComment: UILabel!
    var contactImage:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Add a Contact"
        
        // it's the first view (there's no contact yet)
        if (self.navigationController?.viewControllers[0] == self) {
            self.lbComment.text = "You don't have any contacts yet.\nEnter your first contact to get started."
        } else {
            self.lbComment.text = "You have some contacts.\nEnter phone number and name to have more."
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    @IBAction func onClickChooseFromAB(sender: AnyObject) {
        
        if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined) {
          
            var errorRef: Unmanaged<CFError>? = nil
            let addressBook:ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if success {
                    let picker = ABPeoplePickerNavigationController();
                    picker.peoplePickerDelegate = self;
                    self.presentViewController(picker, animated: true, completion: nil)
                }
            })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            
            let picker = ABPeoplePickerNavigationController();
            picker.peoplePickerDelegate = self;
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }

    func validatePhoneNumber(phoneNumber:String) -> Bool {
        
        if phoneNumber.characters.count > 0 {
            return true;
        }
        else {
            return false;
        }
    }
    
    func validateName(name:String) -> Bool {
        
        if name.characters.count > 0 {
            return true;
        }
        else {
            return false;
        }
    }
    
    @IBAction func onClickAddContact(sender: AnyObject) {
        
        var eb = self.validatePhoneNumber(self.txtPhone.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct phone number.", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)

            return
        }
        
        eb = self.validateName(self.txtName.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct name.", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        var _dicContact = ["isActive":NSNumber(bool: false), "name":self.txtName.text!, "phoneNumber":self.txtPhone.text!, "numberFactsSentPerDay":1]
        
        if self.contactImage != nil {
            let image = self.contactImage!.fixOrientation()
            let profileImage = image.resizeForProfileSize(CGSizeMake(200, 200))
            let imageData:NSData = UIImageJPEGRepresentation(profileImage, 1.0)!
            let file = PFFile(name: "profilePicture.jpg", data: imageData)
            _dicContact["profilePicture"] = file
        }
        
        SVProgressHUD.showWithMaskType(.Black)
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            
            CatFactsApi.reqMyContactCount(nil) { (succeed, count) -> Void in
               
                _dicContact["order"] = NSNumber(int: count)
                
                CatFactsApi.reqNewContact(_dicContact, viewContoller: nil, block: { (succeed, error) -> Void in
                    
                    SVProgressHUD.dismiss()
                    if (succeed == true) {
                        let _vcContacts = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsVC")
                        self.navigationController?.setViewControllers([_vcContacts!], animated: true)
                        SVProgressHUD.showInfoWithStatus("New contact created", maskType: .Black)
                    }
                })
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.Up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        if ( self.imageOrientation == UIImageOrientation.Down || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Left || self.imageOrientation == UIImageOrientation.LeftMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Right || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if ( self.imageOrientation == UIImageOrientation.UpMirrored || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if ( self.imageOrientation == UIImageOrientation.LeftMirrored || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
            CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage),
            CGImageGetBitmapInfo(self.CGImage).rawValue)!;
        
        CGContextConcatCTM(ctx, transform)
        
        if ( self.imageOrientation == UIImageOrientation.Left ||
            self.imageOrientation == UIImageOrientation.LeftMirrored ||
            self.imageOrientation == UIImageOrientation.Right ||
            self.imageOrientation == UIImageOrientation.RightMirrored ) {
                CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(CGImage: CGBitmapContextCreateImage(ctx)!)
    }
    
    func resizeForProfileSize(newSize:CGSize)-> UIImage {
        
        let imageDiameter:CGFloat = 200.0
        var width:CGFloat = self.size.width
        var height:CGFloat = self.size.height
        var scale:CGFloat = 0
        if(width < height) {
            scale = imageDiameter/self.size.width
            width = imageDiameter
            height = height * scale
        }
        else {
            scale = imageDiameter/self.size.height
            width = width * scale
            height = imageDiameter
        }
        
        UIGraphicsBeginImageContext(CGSizeMake(imageDiameter, imageDiameter))
        self.drawInRect(CGRectMake(-(width-imageDiameter)/2.0, -(height-imageDiameter)/2.0, width, height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView: UIImageView = UIImageView(image: newImage)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(imageDiameter/2.0)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
}

extension AddContactVC: ABPeoplePickerNavigationControllerDelegate {
    
    func getPersonFullName(person:ABRecordRef) -> String{
        
        var fullName:String = ""
        
        var abRecord = ABRecordCopyValue(person, kABPersonFirstNameProperty)
        var subName = abRecord != nil ? abRecord.takeRetainedValue() as! String : ""
        fullName = subName
        
        abRecord = ABRecordCopyValue(person, kABPersonMiddleNameProperty)
        subName = abRecord != nil ? abRecord.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        abRecord = ABRecordCopyValue(person, kABPersonLastNameProperty)
        subName = abRecord != nil ? abRecord.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        abRecord = ABRecordCopyValue(person, kABPersonSuffixProperty)
        subName = abRecord != nil ? abRecord.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        abRecord = ABRecordCopyValue(person, kABPersonPrefixProperty)
        subName = abRecord != nil ? abRecord.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        /*
        abRecord = ABRecordCopyValue(person, kABPersonOrganizationProperty)
        subName = abRecord != nil ? abRecord.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        */
        
        return fullName
    }
    
    func displayPerson(person:ABRecordRef) {
        
        txtName.text = ""
        
        let newName = self.getPersonFullName(person)
        if newName == "" {
            SVProgressHUD.showInfoWithStatus("Can't get contact name")
        } else {
            txtName.text = newName
        }
        
        self.contactImage = nil
        
        if let imgData =  ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)?.takeRetainedValue() {
            if let image = UIImage(data: imgData) {
                self.contactImage = image
            }
        }
        
        txtPhone.text = ""
        
        let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
        if unmanagedPhones != nil {
            let phones: ABMultiValueRef = Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
                as NSObject as ABMultiValueRef
            let countOfPhones = ABMultiValueGetCount(phones)
            if countOfPhones > 0 {
                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, 0)
                let phone: String = Unmanaged.fromOpaque(
                    unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
                txtPhone.text = phone
                matchPhoneNumberInTextField(txtPhone, changedLength: phone.characters.count)
            }
            else {
                SVProgressHUD.showInfoWithStatus("No phone number found in contact")
            }
        }
        else {
            SVProgressHUD.showInfoWithStatus("No phone number found in contact")
        }
        
        /*
        let phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue() as? ABMultiValueRef
        var phone:String
        if phoneNumbers != nil && ABMultiValueGetCount(phoneNumbers) > 0 {
            phone = ABMultiValueCopyValueAtIndex(phoneNumbers, 0).takeRetainedValue() as! String
            txtPhone.text = phone
            matchPhoneNumberInTextField(txtPhone, changedLength: phone.characters.count)
        }
        else {
            SVProgressHUD.showInfoWithStatus("Can't get phone number")
            self.contactImage = nil
        }*/
        
        
        /*
        let beginning = txtPhone.beginningOfDocument
        let start = txtPhone.positionFromPosition(beginning, offset: 0)
        let end = txtPhone.positionFromPosition(beginning, offset: phone.characters.count)
        let range = txtPhone.textRangeFromPosition(start!, toPosition: end!)
        self.txtPhone.shouldChangeTextInRange(range!, replacementText: "")
        */
    }
    
    //MARK: - ABPeoplePickerNavigationController Delegates
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        self.displayPerson(person)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddContactVC: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == txtPhone {
            return matchPhoneNumberInTextField(textField, changedLength: range.length)
        }
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
    
    func formatNumber(var mobileNumber:String) -> String {
        
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
    
    func getLength(var mobileNumber:String) -> Int {
        
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("(", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(")", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("-", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("+", withString: "")
        
        let length = mobileNumber.characters.count
        
        return length;
    }
}