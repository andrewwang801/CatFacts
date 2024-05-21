//
//  CatFactsApi.swift
//  CatFacts
//
//  Created by Pae on 12/28/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit
import SVProgressHUD

typealias ReturnBlockError = (Bool, NSError?)->Void
typealias ReturnBlockArray = (Bool, NSArray?)->Void
typealias ResultCount = (Bool, Int32)->Void

class CatFactsApi: NSObject {
    
    static func isNetReachable()->Bool {
        
        let _reach = Reachability.reachabilityForInternetConnection()
        
        if _reach.currentReachabilityStatus() != NotReachable {
            return true;
        }
        else {
            return false;
        }
    }
    
    // MARK: - SignIn & up
    
    static func saveCurUserToInstallation () {
        
        let currentInstallation = PFInstallation.currentInstallation();
        currentInstallation["user"] = GlobInfo.sharedInstance().objCurrentUser;
        if let deviceToken = GlobInfo.sharedInstance().deviceTokenData {
            currentInstallation.setDeviceTokenFromData(deviceToken)
        }
        currentInstallation.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            print(error);
        }
    }

    static func reqSignup(parameters:Dictionary<String, String>, viewController:ViewController?, block:ReturnBlockError) {
        
        if CatFactsApi.isNetReachable() == true {
            let user = PFUser();
            user.username = parameters["email"]?.lowercaseString
            user.password = parameters["password"]!
            user.email = parameters["email"]?.lowercaseString
            
            SVProgressHUD.showWithMaskType(.Black)
            
            user.signUpInBackgroundWithBlock({ (succeeded, error) -> Void in
                
                SVProgressHUD.dismiss()
                if error == nil {
                    GlobInfo.sharedInstance().refreshCurrentUser()
                    CatFactsApi.saveCurUserToInstallation()
                    user.ACL = PFACL(user: user)
                    user.saveInBackground()
                    
                    GlobInfo.sharedInstance().lastEmail = parameters["email"]!
                    
                    // set users
                    block(succeeded, error)
                }
                else {
                    let errorMessage = error?.localizedDescription;
                    CommData.showAlert(errorMessage, withTitle: "Sorry", action: nil)
                    block(false, nil)
                }
            })
        }
        else {
            block(false, nil)
        }
    }

    static func reqSignin(parameters:Dictionary<String, String>, viewController:ViewController?, block:ReturnBlockError) {
        
        if CatFactsApi.isNetReachable() {
            SVProgressHUD.showWithMaskType(.Black)
            
            PFUser.logInWithUsernameInBackground(parameters["email"]!, password: parameters["password"]!, block:{ (user, error) -> Void in
                SVProgressHUD.dismiss()
                if (error == nil) {
                    GlobInfo.sharedInstance().lastEmail = parameters["email"]!
                    GlobInfo.sharedInstance().refreshCurrentUser()
                    CatFactsApi.saveCurUserToInstallation()
                    block(true, error)
                }
                else
                {
                    //let errorMessage = error?.localizedDescription
                    CommData.showAlert("Incorrect email or password.", withTitle: "Sorry", action: nil)
                    block(false, error)
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
    
    static func reqNewContact(parameters:Dictionary<String, AnyObject>, viewContoller:ViewController?, block:ReturnBlockError) {
        
        if (CatFactsApi.isNetReachable()) {
            
            let _pfObjContact = PFObject(className: "Contact", dictionary: parameters)
            
            _pfObjContact["parent"] = GlobInfo.sharedInstance().objCurrentUser
            _pfObjContact.ACL = PFACL(user: GlobInfo.sharedInstance().objCurrentUser)
        
            _pfObjContact.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, error)
                    
                    _pfObjContact.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                        
                        if (error == nil) {
                            block(true, error)
                        }
                        else {
                            let errorMessage = error?.localizedDescription
                            CommData.showAlert(errorMessage, withTitle: "Adding correspond credit failed", action: nil)
                            block(false, error)
                        }
                    })
                }
                else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Adding contact failed.", action: nil)
                    block(false, error)
                }
                
            })
        }
        else {
            block(false, nil)
        }
    }
    
    static func reqMyContactCount(viewController:ViewController?, block:ResultCount){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query:PFQuery = PFQuery(className: "Contact")
            _query.whereKey("parent", equalTo: GlobInfo.sharedInstance().objCurrentUser)
            
            SVProgressHUD.showWithMaskType(.Black)
            _query.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                
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
    
    static func reqMyContactList(viewController:ViewController?, block:ReturnBlockArray){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query = PFQuery(className: "Contact")
            _query.whereKey("parent", equalTo: GlobInfo.sharedInstance().objCurrentUser)
            _query.orderByAscending("order")
            //_query.addDescendingOrder("createdAt")
            //_query.includeKey("credit")
            //_query.includeKey("profilePicture")
            
            SVProgressHUD.showWithMaskType(.Black)
            _query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, objects)
                } else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Loading contact list failed", action: nil)
                    block(false, nil)
                }
            })
        }
    }
    
    static func reqConversationHistory(viewController:ViewController?, contact: PFObject?, block:ReturnBlockArray){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query = PFQuery(className: "Conversation")
            _query.whereKey("contact", equalTo: contact!)
            _query.orderByDescending("createdAt")
            
            SVProgressHUD.showWithMaskType(.Black)
            _query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, objects)
                } else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Loading conversation history failed", action: nil)
                    block(false, nil)
                }
            })
        }
    }
    
    static func reqTheContact(viewController:ViewController?, objectId:String?, block:ReturnBlockArray){
        
        if (CatFactsApi.isNetReachable() == true) {
            
            let _query = PFQuery(className: "Contact")
            _query.whereKey("parent", equalTo: GlobInfo.sharedInstance().objCurrentUser)
                .whereKey("objectId", equalTo: objectId!)
            
            SVProgressHUD.showWithMaskType(.Black)
            _query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in

                SVProgressHUD.dismiss()
                if (error == nil) {
                    block(true, objects)
                } else {
                    let errorMessage = error?.localizedDescription
                    CommData.showAlert(errorMessage, withTitle: "Loading contact list failed", action: nil)
                    block(false, nil)
                }
            })
        }
    }

    static func reqSetContactActive(aObjContact:PFObject, state:Bool, viewController:ViewController?, block:ReturnBlockError) {
        
        aObjContact["isActive"] = state ? true : false
        SVProgressHUD.showWithMaskType(.Black)
        aObjContact.saveInBackgroundWithBlock ({ (succeeded, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error == nil) {
                block(true, nil)
            } else {
                block(false, nil)
            }
        })
    }
    
    static func reqSetContactNumberFactsSentPerDay(aObjContact:PFObject, numberFactsSentPerDay:Int, viewController:ViewController?, block:ReturnBlockError) {
        
        aObjContact["numberFactsSentPerDay"] = numberFactsSentPerDay
        SVProgressHUD.showWithMaskType(.Black)
        aObjContact.saveInBackgroundWithBlock ({ (succeeded, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error == nil) {
                block(true, nil)
            } else {
                block(false, nil)
            }
        })
    }
    
    static func reqDeleteContact(aObjContact:PFObject, viewController:ViewController?, block:ReturnBlockError){

        SVProgressHUD.showWithMaskType(.Black)
        aObjContact.deleteInBackgroundWithBlock { (succeeded, error) -> Void in
            
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
