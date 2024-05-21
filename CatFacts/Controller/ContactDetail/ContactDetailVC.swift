//
//  ContactDetailVC.swift
//  CatFacts
//
//  Created by Work on 16/04/2016.
//  Copyright © 2016 Pae. All rights reserved.
//

import UIKit
import MessageKit
import DropDown
import PhoneNumberKit

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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol ContactDetailVCDelegate: class {
    func dataUpdated()
    func didPurchaseCredit()
}

class ContactDetailVC: UIViewController {

    @IBOutlet weak var editContentView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactPhone: UILabel!
    @IBOutlet weak var buyMoreButton: UIButton!
    @IBOutlet weak var enableSendingMessageSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var editContactImageView: UIImageView!
    @IBOutlet weak var editContactNameField: UITextField!
    @IBOutlet weak var editContactPhoneField: UITextField!
    @IBOutlet weak var showHistoryButton: UIButton!

    @IBOutlet weak var creditsRemainingButton: UIButton!
    @IBOutlet weak var creditsRemainingLabel: UILabel!
    @IBOutlet weak var messagesPerDayButton: UIButton!
    @IBOutlet weak var messagesPerDayLabel: UILabel!

    var contactObj: PFObject? = nil
    var editBtn: UIBarButtonItem? = nil;
    var cancelBtn: UIBarButtonItem? = nil;
    let imagePicker = UIImagePickerController()
    var imageChanged: Bool = false
    weak var delegate: ContactDetailVCDelegate?
    let dropDownView = DropDown()
    var numberOfMessagesPerDay: Int = 1

    enum ContactStatus: Int {
        case sending
        case paused
        case blocked
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Contact Detail"

        self.editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditContacts))
        self.cancelBtn =  UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(endEditing))
        navigationItem.rightBarButtonItem = self.editBtn
        self.editContentView.isHidden = true
        self.contentView.isHidden = false

        self.loadContactData()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.editContentView.addGestureRecognizer(gestureRecognizer)

        self.buyMoreButton.layer.cornerRadius = 5.0;
        self.showHistoryButton.layer.cornerRadius = 5.0;

        self.dropDownView.anchorView = self.messagesPerDayButton
        self.dropDownView.direction = .bottom
        self.dropDownView.bottomOffset = CGPoint(x: 0, y:self.messagesPerDayButton.bounds.height)
        self.dropDownView.dismissMode = .automatic

        self.dropDownView.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

        self.dropDownView.selectionAction = {(index, item) in
            print("item \(item) at index \(index) selected.")
            self.numberOfMessagesPerDay = index+1
            self.saveNumberOfMessagesPerDayToParse()
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.addUnderlineToTextField(self.editContactPhoneField)
        self.addUnderlineToTextField(self.editContactNameField)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationItem.title = "Contact Detail"
    }
    
    // MARK: - Class methods
    
    @objc func toggleEditContacts() {
        
        if self.contactObj == nil {
            return
        }
        
        if self.contentView.isHidden == false {
            
            self.editContactImageView.image = self.contactImageView.image
            self.editContactNameField.text = self.contactName.text
            self.editContactPhoneField.text = self.contactPhone.text
            
            navigationItem.leftBarButtonItem = self.cancelBtn
            self.editBtn?.title = "Done"
            self.editBtn?.isEnabled = false
            self.editContentView.isHidden = false
            self.contentView.isHidden = true
        }
        else {
            //save new settings
            self.saveSettings()
            //self.endEditing()
        }
    }
    
    func validatePhoneNumber(_ phoneNumber:String) -> Bool {
        return phoneNumber.count > 0
    }
    
    func validateName(_ name:String) -> Bool {
        return name.count > 0
    }
    
    func validateMessageCount(_ messageCount:String) -> Bool {
        return messageCount.count > 0
    }
    
    func saveSettings() {
        
        var eb = self.validatePhoneNumber(self.editContactPhoneField.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct phone number.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        eb = self.validateName(self.editContactNameField.text!)
        if (eb == false) {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct name.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
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
        
        SVProgressHUD.show(with: .black)
        
        if let contactData = self.contactObj {
            contactData["name"] = self.editContactNameField.text!
            contactData["phoneNumber"] = self.editContactPhoneField.text!
            //contactData["numberFactsSentPerDay"] = numberPerDay
            
            if self.imageChanged && self.editContactImageView.image != nil {
                let image = self.editContactImageView.image!
                let imageData = image.jpegData(compressionQuality: 1.0)!
                let file = PFFile(name: "profilePicture.jpg", data: imageData)
                contactData["profilePicture"] = file
            }
            
            contactData.saveInBackground(block: { (succeeded, error) -> Void in
                SVProgressHUD.dismiss()
                if (succeeded == true) {
                    SVProgressHUD.showInfo(withStatus: "Changes saved.", maskType: .black)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.loadContactData()
                        self.endEditing()
                        self.delegate?.dataUpdated()
                    })
                }
                else {
                    SVProgressHUD.showError(withStatus: "Failed to update data", maskType: .black)
                }
            })
        }
    }

    func resignAllFirstResponders() {
        
        self.editContactNameField.resignFirstResponder()
        self.editContactPhoneField.resignFirstResponder()
        //self.editContactMessageLimitField.resignFirstResponder()
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        
        self.resignAllFirstResponders()
    }
    
    @objc func endEditing() {

        self.resignAllFirstResponders()
        
        navigationItem.leftBarButtonItem = nil
        self.editBtn?.title = "Edit"
        self.editBtn?.isEnabled = true
        self.editContentView.isHidden = true
        self.contentView.isHidden = false
    }
    
    func contactImageWithContactInformation(_ name:String) -> UIImage? {
        
        let width:CGFloat = 42
        let height:CGFloat = 42
        
        // Find the middle of the circle
        let center = CGPoint(x: width/2.0, y: height/2.0)
        
        // Drawing code
        // Set the radius
        let strokeWidth = 0
        
        let strokeColor = UIColor.lightGray
        let fillColor = UIColor.lightGray
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        
        var context = UIGraphicsGetCurrentContext()
        
        // Set the stroke color
        context!.setStrokeColor(strokeColor.cgColor)
        
        // Set the line width
        context!.setLineWidth(CGFloat(strokeWidth))
        
        // Set the fill color (if you are filling the circle)
        context!.setFillColor(fillColor.cgColor)
        
        context!.fillEllipse(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
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
        let initials = (firstInitial + lastInitial).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        context = UIGraphicsGetCurrentContext()
        
        context!.draw((circularImage?.cgImage)!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let textColor = UIColor.white
        let textFont = UIFont.systemFont(ofSize: 20)
        let attributes = [NSAttributedString.Key.foregroundColor : textColor, NSAttributedString.Key.font : textFont]
        let size = initials.size(withAttributes: attributes)
        initials.draw(at: CGPoint(x: center.x-size.width/2.0, y: center.y-size.height/2.0), withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func loadContactData() {
        
        if let contactData = self.contactObj {
            
            let contactName:String = contactData["name"] as? String ?? ""
            self.contactName.text = contactName
            let phoneNumber:String = contactData["phoneNumber"] as? String ?? ""
            self.contactPhone.text = Utils.getE164Formatted(phoneNumber: phoneNumber)
            
            let imageFile = contactData["profilePicture"] as? PFFile
            if imageFile != nil {
                imageFile!.getDataInBackground { (imageData, error) in
                    if error == nil {
                        let image = UIImage(data: imageData!)
                        self.contactImageView.image = image
                    }
                    else {
                        self.contactImageView.image = self.contactImageWithContactInformation(contactName)
                    }
                }
            }
            else {
                self.contactImageView.image = self.contactImageWithContactInformation(contactName)
            }
            
            self.numberOfMessagesPerDay = contactData["numberFactsSentPerDay"] as? Int ?? 1
            self.messagesPerDayLabel.text = "\(self.numberOfMessagesPerDay)"
            self.creditsRemainingLabel.text = "\(contactData["numberCredits"] as? Int ?? 0)"

            let isActive = contactData["isActive"] as? Bool ?? false
            let isBlacklisted = contactData["isBlacklisted"] as? Bool ?? false
            self.enableSendingMessageSwitch.isOn = isActive

            var contactStatus: ContactStatus = .sending
            if isActive == true {
                if isBlacklisted == false {
                    contactStatus = .sending
                }
                else {
                    contactStatus = .blocked
                }
            }
            else {
                contactStatus = .paused
            }
            let statusColor = kContactStatusColorArray[contactStatus.rawValue]
            let statusText = kContactStatusTextArray[contactStatus.rawValue]
            statusLabel.text = statusText
            statusLabel.textColor = statusColor
        }
    }
    
    func saveNumberOfMessagesPerDayToParse() {

        SVProgressHUD.show(with: .black)
        
        let numberPerDay:Int = self.numberOfMessagesPerDay
        
        if let contactData = self.contactObj {
            contactData["numberFactsSentPerDay"] = numberPerDay
            contactData.saveInBackground(block: { (succeeded, error) -> Void in
                SVProgressHUD.dismiss()
                if (succeeded == true) {
                    SVProgressHUD.showInfo(withStatus: "Changes saved.", maskType: .black)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.messagesPerDayLabel.text = "\(self.numberOfMessagesPerDay)"
                        self.delegate?.dataUpdated()
                    })
                }
                else {
                    SVProgressHUD.showError(withStatus: "Failed to update data", maskType: .black)
                }
            })
        }
    }
    
    func addUnderlineToTextField(_ txtField:UITextField) {
        let border = CALayer()
        let width = 1.0/UIScreen.main.scale
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: txtField.frame.size.height - width, width:  txtField.frame.size.width, height: txtField.frame.size.height)
        border.borderWidth = width
        txtField.layer.addSublayer(border)
        txtField.layer.masksToBounds = true
    }
    
    func loadConversationData() {
        var messages = [MockMessage]()
        let contactName = contactObj!["name"] as? String ?? ""
        CatFactsApi.reqConversationHistory(nil, contact: contactObj) { (succeed, aArrResult) -> Void in
            if (succeed) {
                if aArrResult?.count > 0 {
                    for i in 0...aArrResult!.count - 1 {
                        let conversationObj = aArrResult![i] as! PFObject
                        var senderId = ""
                        var displayName = ""
                        if conversationObj["isContactResponse"] as! Bool  == true {
                            senderId = kChatContactId
                            displayName = contactName
                        } else {
                            senderId = kChatServerId
                            displayName = kChatServerName
                        }

                        let sender = Sender(id: senderId, displayName: displayName)
                        let messageContent = conversationObj["message"] as! String
                        let date = conversationObj.createdAt!
                        let message = MockMessage(text: messageContent, sender: sender, messageId: NSUUID().uuidString, date: date)
                        messages.append(message)
                    }

                    let contactSender = Sender(id: kChatContactId, displayName: contactName)
                    self.openMessageView(messages, contactSender: contactSender)
                } else {
                    self.showNoMessageAlert()
                }
            }
        }
    }
    
    func openMessageView(_ messages: [MockMessage], contactSender: Sender) {
        if let contactData = self.contactObj {
            if let chatViewController =  self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                self.navigationItem.title = "";
                chatViewController.theContact = contactData
                chatViewController.messageList = messages
                chatViewController.contactSender = contactSender
                self.navigationController?.pushViewController(chatViewController, animated: true)
            }
        }
    }
    
    func showNoMessageAlert() {
        let messageErrorAlert = UIAlertView(title: "", message: "No messages!", delegate: self, cancelButtonTitle: "OK")
        messageErrorAlert.show()
    }

    func presentCreditItemSelectVC(activateAfterPurchase: Bool) {

        if let contactData = self.contactObj {
            if let creditItemSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "CreditItemSelectVC") as? CreditItemSelectVC {
                self.navigationItem.title = "";
                creditItemSelectVC.theContact = contactData
                creditItemSelectVC.activateAfterPurchase = activateAfterPurchase
                creditItemSelectVC.delegate = self
                self.navigationController?.pushViewController(creditItemSelectVC, animated: true)
            }
        }
    }
    
    func showTransferDialog() {
        if let transferDialog = self.storyboard?.instantiateViewController(withIdentifier: "TransferDialog") as? TransferDialog {
            transferDialog.currentObj = self.contactObj
            transferDialog.dismissHandler = { ( returnCode ) -> () in
                
                if returnCode == TransferDialog.ReturnCode.left {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.loadContactData()
                    })
                }
            }
            transferDialog.modalPresentationStyle = .overFullScreen
            present(transferDialog, animated: true)
        }
    }

    @IBAction func changePhoto() {

        self.imagePicker.delegate = self

        let optionMenu = UIAlertController(title: nil, message: "Choose Picture", preferredStyle: .actionSheet)

        let cameraRollAction = UIAlertAction(title: "From Camera Roll", style: .default) { (alert) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        let takePictureAction = UIAlertAction(title: "Take Picture", style: .default) { (alert) in
            self.imagePicker.sourceType = .camera
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }

        optionMenu.addAction(cameraRollAction)
        optionMenu.addAction(takePictureAction)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func onMessagesPerDay(_ sender: Any) {
        if self.dropDownView.isHidden == false {
            self.dropDownView.hide()
        }
        else {
            self.dropDownView.reloadAllComponents()
            self.dropDownView.selectRow(self.numberOfMessagesPerDay-1)
            let _ = self.dropDownView.show()
        }
    }

    @IBAction func onCreditsRemaining(_ sender: Any) {
        presentCreditItemSelectVC(activateAfterPurchase: false)
    }

    @IBAction func showHistory(_ sender: AnyObject) {
        loadConversationData()
    }

    @IBAction func onBuyMoreCredit(_ sender: Any) {
        presentCreditItemSelectVC(activateAfterPurchase: false)
    }
    
    @IBAction func onTransfer(_ sender: Any) {
        showTransferDialog()
    }
    
    @IBAction func onEnableSendingMessage(_ sender: Any) {

        if let contactData = self.contactObj {

            let credit = contactData["numberCredits"] as? Int ?? 0

            if credit <= 0 && enableSendingMessageSwitch.isOn == true {
                presentCreditItemSelectVC(activateAfterPurchase: true)
                enableSendingMessageSwitch.setOn(false, animated: true)
                return
            }

            CatFactsApi.reqSetContactActive(contactData, state: enableSendingMessageSwitch.isOn, viewController: nil, block: { (succeed, aArrResult) -> Void in
                if (succeed == false) {
                    self.enableSendingMessageSwitch.setOn(!self.enableSendingMessageSwitch.isOn, animated: true)
                }
            })
        }
    }

}

extension ContactDetailVC: CreditItemSelectVCDelegate {

    func didPurchaseCredit() {

        self.delegate?.didPurchaseCredit()

        //SVProgressHUD.show()
        self.contactObj?.fetchInBackground(block: { (object, error) in
            //SVProgressHUD.dismiss()
            if error == nil {
                self.contactObj = object
                DispatchQueue.main.async(execute: {
                    self.loadContactData()
                })
            }
        })
    }
}

extension ContactDetailVC: UITextFieldDelegate {

    //MARK: TextField

    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        let nextTag = textField.tag + 1
        if let nextField: UITextField = self.view.viewWithTag(nextTag) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        self.editBtn!.isEnabled = true

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

    func matchPhoneNumberInTextField(_ textField: UITextField, changedLength: Int) -> Bool {

        let phoneText = textField.text ?? ""
        if phoneText.starts(with: "+") {
            return true
        }

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
                textField.text = "\((num as NSString).substring(to: 3))"
            }
        }
        else if length == 6 {
            let num = formatNumber(textField.text!)
            textField.text = "(\((num as NSString).substring(to: 3))) \((num as NSString).substring(from: 3))-"

            if changedLength > 0 {
                textField.text = "(\((num as NSString).substring(to: 3))) \((num as NSString).substring(from: 3))"
            }
        }
        else if length == 10 {
            let num = formatNumber(textField.text!)

            if changedLength > 0 {
                textField.text = "(\((num as NSString).substring(to: 3))) \((num as NSString).substring(with: NSRange.init(location: 3,length: 3)))-\((num as NSString).substring(from: 6))"
            }
        }

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

extension ContactDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let fixOrientationImage = image.fixOrientation()
        let resizedImage = fixOrientationImage.resizeForProfileSize(CGSize(width: 200, height: 200))

        self.editContactImageView.image = resizedImage
        self.editBtn!.isEnabled = true

        self.imageChanged = true

        self.dismiss(animated: true, completion: nil)
    }
}
