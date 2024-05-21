//
//  SignInVC.swift
//  CatFacts
//
//  Created by Pae on 12/28/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit

class SignInVC: CFBaseVC {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPasswd: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initUI()
    }
    
    func initUI() {
    }

    override func viewWillAppear(animated:Bool) {
        
        self.navigationItem.title = "Welcome"
    }
    
    func validateEmail(email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(email)
        
        return result
    }
    
    func validatePasswd(passwd: String) -> Bool {
        
        return passwd.characters.count != 0
    }
    
    @IBAction func onClickSignin(sender: AnyObject) {
        
        var eb = self.validateEmail(self.txtEmail.text!)
        
        if (eb == false) {
            
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct Email address.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        eb = self.validatePasswd(self.txtPasswd.text!)
        
        if (eb == false) {
            
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct password.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        CatFactsApi.reqSignin(["email":self.txtEmail.text!.lowercaseString, "password":self.txtPasswd.text!], viewController: nil) { (succeed, error) -> Void in
            
            if (succeed == true) {
                if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    delegate.gotoMain()
                }
            }
        }

    }
    
    @IBAction func onClickSignup(sender: AnyObject) {
        
        let _vcSignup = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpVC")
        self.navigationController?.setViewControllers([_vcSignup!], animated: true)
    }
    
    @IBAction func onClickForgotPasswd(sender: AnyObject) {
        
        let _vcAlert = UIAlertController(title: "Reset Password", message: "Please enter your email address to reset your password.", preferredStyle: .Alert)
        
        _vcAlert.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter email address"
            textField.keyboardType = .EmailAddress
        }
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            
            let txtField = _vcAlert.textFields?.first;
            PFUser.requestPasswordResetForEmailInBackground(txtField!.text!);
            CommData.showAlert("Please check your Email inbox.", withTitle: "", action: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        _vcAlert.addAction(okAction)
        _vcAlert.addAction(cancelAction)
        self.presentViewController(_vcAlert, animated: true, completion: nil)
    }
    
    @IBAction func onLogoLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://www.catfactstexts.com/")!)
    }
}
