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

    override func viewWillAppear(_ animated:Bool) {
        
        self.navigationItem.title = "Welcome"
    }
    
    func validateEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        
        return result
    }
    
    func validatePasswd(_ passwd: String) -> Bool {
        
        return passwd.characters.count != 0
    }
    
    @IBAction func onClickSignin(_ sender: AnyObject) {
        
        var eb = self.validateEmail(self.txtEmail.text!)
        
        if (eb == false) {
            
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct Email address.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        eb = self.validatePasswd(self.txtPasswd.text!)
        
        if (eb == false) {
            
            let alert = UIAlertController(title: "Sorry", message: "Please enter correct password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        CatFactsApi.reqSignin(["email":self.txtEmail.text!.lowercased(), "password":self.txtPasswd.text!], viewController: nil) { (succeed, error) -> Void in
            
            if (succeed == true) {
                Utils.setBoolSetting(key: kUUIDSignedUpKey, value: false)
                if let delegate = UIApplication.shared.delegate as? AppDelegate {
                    delegate.gotoMain()
                }
            }
        }

    }
    
    @IBAction func onClickSignup(_ sender: AnyObject) {
        
        let _vcSignup = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC")
        self.navigationController?.setViewControllers([_vcSignup!], animated: true)
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
