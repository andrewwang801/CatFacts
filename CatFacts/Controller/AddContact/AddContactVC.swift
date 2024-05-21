//
//  AddContactVC.swift
//  CatFacts
//
//  Created by Pae on 12/29/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit
import PhoneNumberKit
import DropDown
import IBAnimatable

class AddContactVC: CFBaseVC {

    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var lbComment: UILabel!
    @IBOutlet weak var countryCodeView: AnimatableView!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    
    var contactImage:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupDropDown()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Add a Contact"
        
        // it's the first view (there's no contact yet)
        if (self.navigationController?.viewControllers[0] == self) {
            self.lbComment.text = "You don't have any contacts yet.\nEnter your first contact to get started."
        } else {
            self.lbComment.text = "Enter a phone number and name below, then tap the Add Contact button."
        }
    }
    
    // MARK Country code dropdown
    let dropDown = DropDown()
    
    @IBAction func onCountryCode(_ sender: Any) {
        dropDown.show()
    }
    
    func setupDropDown() {
        dropDown.anchorView = countryCodeView
        dropDown.dataSource = kFlagValues
        dropDown.cellNib = UINib(nibName: "CountryCodeCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CountryCodeCell else { return }
            cell.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
        }
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
            self.countryCodeLabel.text = item
        }
    }

    func extractABAddressBookRef(_ abRef: Unmanaged<ABAddressBook>!) -> ABAddressBook? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    @IBAction func onClickChooseFromAB(_ sender: AnyObject) {
        
        if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.notDetermined) {
          
            var errorRef: Unmanaged<CFError>? = nil
            let addressBook:ABAddressBook? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if success {
                    let picker = ABPeoplePickerNavigationController();
                    picker.peoplePickerDelegate = self;
                    picker.modalPresentationStyle = .fullScreen
                    self.present(picker, animated: true, completion: nil)
                }
            })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.restricted) {
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.authorized) {
            
            let picker = ABPeoplePickerNavigationController();
            picker.peoplePickerDelegate = self;
            picker.modalPresentationStyle = .fullScreen
            self.present(picker, animated: true, completion: nil)
        }
    }

    func validatePhoneNumber(_ phoneNumber:String) -> Bool {
        
        if phoneNumber.count > 0 {
            return true;
        }
        else {
            return false;
        }
    }
    
    func validateName(_ name:String) -> Bool {
        
        if name.count > 0 {
            return true;
        }
        else {
            return false;
        }
    }
    
    @IBAction func onClickAddContact(_ sender: AnyObject) {
        
        var eb = self.validatePhoneNumber(self.countryCodeLabel.text! + self.txtPhone.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct phone number.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)

            return
        }
        
        eb = self.validateName(self.txtName.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct name.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        var _dicContact: [String: Any] = ["isActive":NSNumber(value: false as Bool), "name":self.txtName.text!, "phoneNumber":self.txtPhone.text!, "numberFactsSentPerDay":1]
        
        if self.contactImage != nil {
            let image = self.contactImage!.fixOrientation()
            let profileImage = image.resizeForProfileSize(CGSize(width: 200, height: 200))
            let imageData = profileImage.jpegData(compressionQuality: 1.0)!
            let file = PFFile(name: "profilePicture.jpg", data: imageData)
            _dicContact["profilePicture"] = file
        }
        
        SVProgressHUD.show(with: .black)

        DispatchQueue.global().async {

            CatFactsApi.reqMyContactCount(nil) { (succeed, count) -> Void in

                _dicContact["order"] = NSNumber(value: count as Int32)

                CatFactsApi.reqNewContact(_dicContact, viewContoller: nil, block: { (succeed, error) -> Void in

                    SVProgressHUD.dismiss()
                    if (succeed == true) {
                        let _vcContacts = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC")
                        self.navigationController?.setViewControllers([_vcContacts!], animated: true)
                        SVProgressHUD.showInfo(withStatus: "New contact created", maskType: .black)
                    }
                })
            }
        }
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
        if ( self.imageOrientation == UIImage.Orientation.up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if ( self.imageOrientation == UIImage.Orientation.down || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.left || self.imageOrientation == UIImage.Orientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.right || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi/2));
        }
        
        if ( self.imageOrientation == UIImage.Orientation.upMirrored || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if ( self.imageOrientation == UIImage.Orientation.leftMirrored || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
            bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
            space: self.cgImage!.colorSpace!,
            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;
        
        ctx.concatenate(transform)
        
        if ( self.imageOrientation == UIImage.Orientation.left ||
            self.imageOrientation == UIImage.Orientation.leftMirrored ||
            self.imageOrientation == UIImage.Orientation.right ||
            self.imageOrientation == UIImage.Orientation.rightMirrored ) {
                ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
    
    func resizeForProfileSize(_ newSize:CGSize)-> UIImage {
        
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
        
        UIGraphicsBeginImageContext(CGSize(width: imageDiameter, height: imageDiameter))
        self.draw(in: CGRect(x: -(width-imageDiameter)/2.0, y: -(height-imageDiameter)/2.0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView: UIImageView = UIImageView(image: newImage)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(imageDiameter/2.0)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
}

extension AddContactVC: ABPeoplePickerNavigationControllerDelegate {
    
    func getPersonFullName(_ person:ABRecord) -> String{
        
        var fullName:String = ""
        
        var abRecord = ABRecordCopyValue(person, kABPersonFirstNameProperty)
        var subName = abRecord != nil ? abRecord?.takeRetainedValue() as! String : ""
        fullName = subName
        
        abRecord = ABRecordCopyValue(person, kABPersonMiddleNameProperty)
        subName = abRecord != nil ? abRecord?.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        abRecord = ABRecordCopyValue(person, kABPersonLastNameProperty)
        subName = abRecord != nil ? abRecord?.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        abRecord = ABRecordCopyValue(person, kABPersonSuffixProperty)
        subName = abRecord != nil ? abRecord?.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        abRecord = ABRecordCopyValue(person, kABPersonPrefixProperty)
        subName = abRecord != nil ? abRecord?.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        
        /*
        abRecord = ABRecordCopyValue(person, kABPersonOrganizationProperty)
        subName = abRecord != nil ? abRecord.takeRetainedValue() as! String : ""
        fullName = fullName + (subName != "" ? " \(subName)" : "")
        */
        
        return fullName
    }
    
    func displayPerson(_ person:ABRecord) {
        
        txtName.text = ""
        
        let newName = self.getPersonFullName(person)
        if newName == "" {
            SVProgressHUD.showInfo(withStatus: "Can't get contact name")
        } else {
            txtName.text = newName
        }
        
        self.contactImage = nil
        
        if let imgData =  ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)?.takeRetainedValue() {
            if let image = UIImage(data: imgData as Data) {
                self.contactImage = image
            }
        }
        
        txtPhone.text = ""
        
        let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
        if unmanagedPhones != nil {
            let phones: ABMultiValue = Unmanaged.fromOpaque(unmanagedPhones!.toOpaque()).takeUnretainedValue()
                as NSObject as ABMultiValue
            let countOfPhones = ABMultiValueGetCount(phones)
            if countOfPhones > 0 {
                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, 0)
                let phone: String = Unmanaged.fromOpaque(
                    unmanagedPhone!.toOpaque()).takeUnretainedValue() as NSObject as! String
                txtPhone.text = phone
                let _ = matchPhoneNumberInTextField(txtPhone, changedLength: phone.characters.count)
            }
            else {
                SVProgressHUD.showInfo(withStatus: "No phone number found in contact")
            }
        }
        else {
            SVProgressHUD.showInfo(withStatus: "No phone number found in contact")
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
    
    func peoplePickerNavigationControllerDidCancel(_ peoplePicker: ABPeoplePickerNavigationController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        self.displayPerson(person)
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddContactVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtPhone {
            return matchPhoneNumberInTextField(textField, changedLength: range.length)
        }
        return true
    }
    
    func matchPhoneNumberInTextField(_ textField: UITextField, changedLength: Int) -> Bool {

        let phoneText = textField.text ?? ""
        if phoneText.starts(with: "+") {
            return true
        }

        let length = getLength(textField.text!)
        
        /*if length == 10 {
            if changedLength == 0 {
                return false;
            }
        }*/
        
        if length == 3 {
            let num = formatNumber(textField.text!)
            textField.text = "(\(num)) "
            
            if changedLength > 0 {
                textField.text = "\((num as NSString).substring(to: 3))"
            }
        }
        /*else if length == 6 {
            let num = formatNumber(textField.text!)
            textField.text = "(\((num as NSString).substring(to: 3))) \((num as NSString).substring(from: 3))-"
            
            if changedLength > 0 {
                textField.text = "(\((num as NSString).substring(to: 3))) \((num as NSString).substring(from: 3))"
            }
        }*/
        /*else if length == 10 {
            let num = formatNumber(textField.text!)
            
            if changedLength > 0 {
                textField.text = "(\((num as NSString).substring(to: 3))) \((num as NSString).substring(with: NSRange.init(location: 3,length: 3)))-\((num as NSString).substring(from: 6))"
            }
        }*/
        
        return true;
    }
    
    func formatNumber(_ mobileNumber:String) -> String {
        var mobileNumber = mobileNumber
        
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
        
        let length = mobileNumber.count

        if length > 10 {
            mobileNumber = (mobileNumber as NSString).substring(from: length-10)
        }
    
        return mobileNumber;
    }
    
    func getLength(_ mobileNumber:String) -> Int {
        var mobileNumber = mobileNumber
        
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
        
        let length = mobileNumber.count
        
        return length;
    }
}
