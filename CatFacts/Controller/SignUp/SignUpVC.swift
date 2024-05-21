//
//  SignUpVC.swift
//  CatFacts
//
//  Created by Pae on 12/29/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit

class SignUpVC: CFBaseVC {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPasswd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Sign Up for Free"
    }
    
    func validateEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        
        return result
    }
    
    func validatePasswd(_ passwd: String) -> Bool {
        
        return passwd.count != 0
    }
    
    @IBAction func onClickSignup(_ sender: AnyObject) {
        
        var eb = self.validateEmail(self.txtEmail.text!)
        if (eb == false)
        {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct Email address.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        eb = self.validatePasswd(self.txtPasswd.text!)
        if (eb == false)
        {
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        CatFactsApi.reqSignup(["email":self.txtEmail.text!.lowercased(), "password":self.txtPasswd.text!], viewController: nil) { (succeed, error) -> Void in
            
            if (succeed) {
                Utils.setBoolSetting(key: kUUIDSignedUpKey, value: false)
                if let delegate = UIApplication.shared.delegate as? AppDelegate {
                    delegate.gotoMain()
                }
            }
        }
        
    }
    
    @IBAction func onSkipSignup(_ sender: Any) {

        let _vcAlert = UIAlertController(title: "Skip Signup", message: "Note: You chose to skip sign up and we’ve used a temporary token to identify your device for this session only. However, your data will be lost if you choose to Log Out from the main menu.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Skip", style: .default) { (action) -> Void in
            // we should do delete the card
            self.doSkipSignup()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        _vcAlert.addAction(cancelAction)
        _vcAlert.addAction(okAction)
        self.present(_vcAlert, animated: true, completion: nil)
    }

    func doSkipSignup() {
        // get device token and save it
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        if uuid == "" {
            SVProgressHUD.showError(withStatus: "Could not get the device id")
            return
        }

        var tempEmail = uuid.replacingOccurrences(of: "-", with: "")
        tempEmail = tempEmail.lowercased()
        let timeStamp = Int(Date().timeIntervalSince1970)
        tempEmail += "@\(timeStamp).com"

        // sign up with and default pwd
        CatFactsApi.reqSignup(["email":tempEmail, "password":kUUIDSignupPwd], viewController: nil) { (succeed, error) -> Void in

            if (succeed) {
                Utils.setBoolSetting(key: kUUIDSignedUpKey, value: true)
                if let delegate = UIApplication.shared.delegate as? AppDelegate {
                    delegate.gotoMain()
                }
            }
        }
    }

    @IBAction func onClickSignin(_ sender: AnyObject) {
        
        let _vcSignin = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
        self.navigationController?.setViewControllers([_vcSignin!], animated: true)
    }
    
    @IBAction func onClickForgotPasswd(_ sender: AnyObject) {
        
        let _vcAlert = UIAlertController(title: "Reset Password", message: "Please enter your email address to reset your password.", preferredStyle: .alert)
        
        _vcAlert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter email address"
            textField.keyboardType = .emailAddress
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            let txtField = _vcAlert.textFields?.first;
            PFUser.requestPasswordResetForEmail(inBackground: txtField!.text!);
            CommData.showAlert("Please check your Email inbox.", withTitle: "", action: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        _vcAlert.addAction(okAction)
        _vcAlert.addAction(cancelAction)
        self.present(_vcAlert, animated: true, completion: nil)
    }

    @IBAction func onLogoLink(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string:"http://www.catfactstexts.com/")!)
    }
}
