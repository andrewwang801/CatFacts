//
//  CatFactsApi.swift
//  CatFacts
//
//  Created by Pae on 12/28/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit
//import SVProgressHUD

typealias ReturnBlockError = (Bool, NSError?)->Void
typealias ReturnBlockArray = (Bool, NSArray?)->Void
typealias ResultCount = (Bool, Int32)->Void

class CatFactsApi: NSObject {
    
    static func isNetReachable()->Bool {
        
        let _reach = Reachability.forInternetConnection()
        
        if _reach?.currentReachabilityStatus() != NotReachable {
            return true;
        }
        else {
            return false;
        }
    }
    
    // MARK: - SignIn & up
    
    static func saveCurUserToInstallation () {
        
        let currentInstallation = PFInstallation.current();
        currentInstallation["user"] = GlobInfo.sharedInstance().objCurrentUser;
        if let deviceToken = GlobInfo.sharedInstance().deviceTokenData {
            currentInstallation.setDeviceTokenFrom(deviceToken)
        }
        currentInstallation.saveInBackground { (success, error) in
            if error != nil {
                NSLog(error!.localizedDescription)
            }
        }
    }

    static func reqSignup(_ parameters:[String: String], viewController:ViewController?, block:@escaping ReturnBlockError) {
        
        if CatFactsApi.isNetReachable() == true {
            let user = PFUser();
            user.username = parameters["email"]?.lowercased()
            user.password = parameters["password"]!
            user.email = parameters["email"]?.lowercased()
            
            SVProgressHUD.show(with: .black)
            
            user.signUpInBackground(block: { (succeeded, error) -> Void in

                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if error == nil {
                        GlobInfo.sharedInstance().refreshCurrentUser()
                        CatFactsApi.saveCurUserToInstallation()
                        user.acl = PFACL(user: user)
                        user.saveInBackground()

                        GlobInfo.sharedInstance().lastEmail = parameters["email"]!

                        // set users
                        block(succeeded, nil)
                    }
                    else {
                        let errorMessage = error?.localizedDescription;
                        CommData.showAlert(errorMessage, withTitle: "Sorry", action: nil)
                        block(false, nil)
                    }
                }
            })
        }
        else {
            block(false, nil)
        }
    }

    static func reqSignin(_ parameters:[String: String], viewController:ViewController?, block:@escaping ReturnBlockError) {
        
        if CatFactsApi.isNetReachable() {
            SVProgressHUD.show(with: .black)
            
            PFUser.logInWithUsername(inBackground: parameters["email"]!, password: parameters["password"]!, block:{ (user, error) -> Void in

                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if (error == nil) {
                        GlobInfo.sharedInstance().lastEmail = parameters["email"]!
                        GlobInfo.sharedInstance().refreshCurrentUser()
                        CatFactsApi.saveCurUserToInstallation()
                        block(true, nil)
                    }
                    else
                    {
                        //let errorMessage = error?.localizedDescription
                        CommData.showAlert("Incorrect email or password.", withTitle: "Sorry", action: nil)
                        block(false, error! as NSError)
                    }
                }
            })
        }
        else {
            block(false, nil)
        }
    }
    
    static func logout() {
        PFUser.logOut()
    }

// MARK: - New Contact
    
    static func reqNewContact(_ parameters:[String: Any], viewContoller:ViewController?, block:@escaping ReturnBlockError) {
        
        if (CatFactsApi.isNetReachable()) {

            let _pfObjContact = PFObject(className: "Contact", dictionary: parameters)
            
            _pfObjContact["parent"] = GlobInfo.sharedInstance().objCurrentUser
            _pfObjContact.acl = PFACL(user: GlobInfo.sharedInstance().objCurrentUser)
        
            _pfObjContact.saveInBackground(block: { (succeeded, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, nil)

                    /*
                    _pfObjContact.saveInBackground(block: { (succeeded, error) -> Void in
                        
                        if (error == nil) {
                            block(true, nil)
                        }
                        else {
                            let errorMessage = error?.localizedDescription
                            CommData.showAlert(errorMessage, withTitle: "Adding correspond credit failed", action: nil)
                            block(false, error! as NSError)
                        }
                    })*/
                }
                else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Adding contact failed.", action: nil)
                    block(false, error! as NSError)
                }
                
            })
        }
        else {
            block(false, nil)
        }
    }
    
    static func reqMyContactCount(_ viewController:ViewController?, block:@escaping ResultCount){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query:PFQuery = PFQuery(className: "Contact")
            _query.whereKey("parent", equalTo: GlobInfo.sharedInstance().objCurrentUser)
            
            SVProgressHUD.show(with: .black)
            _query.countObjectsInBackground(block: { (count, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error == nil) {
                    // The count request succeeded.
                    block(true, count)
                }
                else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Counting my contacts failed!", action: nil)
                    block(false, 0)
                }
            })
        }
        else {
            block(false, 0)
        }
    }
    
    static func reqMyContactList(_ viewController:ViewController?, block:@escaping ReturnBlockArray){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query = PFQuery(className: "Contact")
            _query.whereKey("parent", equalTo: GlobInfo.sharedInstance().objCurrentUser)
            _query.order(byAscending: "order")
            //_query.addDescendingOrder("createdAt")
            //_query.includeKey("credit")
            //_query.includeKey("profilePicture")
            
            SVProgressHUD.show(with: .black)
            _query.findObjectsInBackground(block: { (objects, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, objects! as NSArray)
                } else {
                    let errorMessage = error!.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Loading contact list failed", action: nil)
                    block(false, nil)
                }
            })
        }
    }
    
    static func reqConversationHistory(_ viewController:ViewController?, contact: PFObject?, block:@escaping ReturnBlockArray){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query = PFQuery(className: "Conversation")
            _query.whereKey("contact", equalTo: contact!)
            _query.order(byAscending: "createdAt")
            
            SVProgressHUD.show(with: .black)
            _query.findObjectsInBackground(block: { (objects, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, objects! as NSArray)
                } else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Loading conversation history failed", action: nil)
                    block(false, nil)
                }
            })
        }
    }
    
    static func reqTheContact(_ viewController:ViewController?, objectId:String?, block:@escaping ReturnBlockArray){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query = PFQuery(className: "Contact")
            _query.whereKey("parent", equalTo: GlobInfo.sharedInstance().objCurrentUser)
                .whereKey("objectId", equalTo: objectId!)
            
            SVProgressHUD.show(with: .black)
            _query.findObjectsInBackground(block: { (objects, error) -> Void in

                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, objects! as NSArray)
                } else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Loading contact list failed", action: nil)
                    block(false, nil)
                }
            })
        }
    }

    static func reqSetContactActive(_ aObjContact:PFObject, state:Bool, viewController:ViewController?, block:@escaping ReturnBlockError) {
        
        aObjContact["isActive"] = state ? true : false
        SVProgressHUD.show(with: .black)
        aObjContact.saveInBackground (block: { (succeeded, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error == nil) {
                block(true, nil)
            } else {
                block(false, nil)
            }
        })
    }
    
    static func reqSetContactNumberFactsSentPerDay(_ aObjContact:PFObject, numberFactsSentPerDay:Int, viewController:ViewController?, block:@escaping ReturnBlockError) {
        
        aObjContact["numberFactsSentPerDay"] = numberFactsSentPerDay
        SVProgressHUD.show(with: .black)
        aObjContact.saveInBackground (block: { (succeeded, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error == nil) {
                block(true, nil)
            } else {
                block(false, nil)
            }
        })
    }
    
    static func reqDeleteContact(_ aObjContact:PFObject, viewController:ViewController?, block:@escaping ReturnBlockError){

        SVProgressHUD.show(with: .black)
        aObjContact.deleteInBackground { (succeeded, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error == nil) {
                block(true, nil)
            } else {
                let errorMessage = error?.localizedDescription
                CommData.showAlert(errorMessage, withTitle: "Can't delete contact", action: nil)
                block(false, nil)
            }
        }
    }
}
