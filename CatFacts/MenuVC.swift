//
//  MenuVC.swift
//  CatFacts
//
//  Created by Work on 15/04/2016.
//  Copyright © 2016 Pae. All rights reserved.
//

import UIKit
import MessageUI

class MenuVC: UITableViewController, MFMailComposeViewControllerDelegate {
    
    enum TableRow {
        case About, InviteFriends, FeedbackAndSupport, Logout
        
        init?(row: Int) {
            switch (row) {
            case 0:
                self = .About
            case 1:
                self = .InviteFriends
            case 2:
                self = .FeedbackAndSupport
            case 3:
                self = .Logout
            default:
                return nil
            }
        }
    }
    
    //MARK: - Email Composer

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configuredMailComposeViewController()
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        //mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property

        mailComposerVC.setToRecipients(["info@catfactstexts.com"])
        mailComposerVC.setSubject("Feedback & Support")
        mailComposerVC.mailComposeDelegate = self
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.deselectSelectedIndexPath()
    }
    
    //MARK: - Methods
    
    func inviteFriends() {
        let textToShare = ""
        if let appStoreURL = NSURL(string: AppStoreLink) {
            let objectsToShare = [textToShare, appStoreURL]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: nil)
            
            self.deselectSelectedIndexPath()
        }
    }
    
    func logout() {
        CatFactsApi.logout()
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.gotoSignin()
        }
    }
    
    func showAboutMenu() {
        if let aboutUsVC =  self.storyboard?.instantiateViewControllerWithIdentifier("AboutUs") as? AboutUs {
            let navController = UINavigationController(rootViewController: aboutUsVC)
            self.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    //MARK: - TableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (TableRow(row: indexPath.row)!) {
        case .About:
            self.showAboutMenu()
            break
        case .InviteFriends:
            self.inviteFriends()
            break;
        case .FeedbackAndSupport:
            self.sendEmail()
            break;
        case .Logout:
            self.logout()
            break;
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func deselectSelectedIndexPath() {
        if let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.deselectSelectedIndexPath()
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            revealViewController().rightViewRevealWidth = 100
        }
        
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
