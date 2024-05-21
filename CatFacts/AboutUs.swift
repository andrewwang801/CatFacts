//
//  AboutUs.swift
//  CatFacts
//
//  Created by Work on 15/04/2016.
//  Copyright © 2016 Pae. All rights reserved.
//

import UIKit

class AboutUs: UITableViewController, SKStoreProductViewControllerDelegate {
    
    @IBOutlet weak var versionNoLabel:UILabel!
    
    enum TableRow {
        case RateUs, LikeUsOnFacebook, FollowUsOnTwitter, PrivacyPolicy, TermsOfService, VisitOurWebsite
        
        init?(row: Int) {
            switch (row) {
            case 0:
                self = .RateUs
            case 1:
                self = .LikeUsOnFacebook
            case 2:
                self = .FollowUsOnTwitter
            case 3:
                self = .PrivacyPolicy
            case 4:
                self = .TermsOfService
            case 5:
                self = .VisitOurWebsite
            default:
                return nil
            }
        }
    }
    //MARK: - Methods
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func rateUs() {
        if let appStoreURL = NSURL(string: AppStoreLink) {
            UIApplication.sharedApplication().openURL(appStoreURL)
        }
        self.deselectSelectedIndexPath()
        
        /*
        let vc: SKStoreProductViewController = SKStoreProductViewController()
        let params = [
            SKStoreProductParameterITunesItemIdentifier:1074493881
        ]
        vc.delegate = self
        vc.loadProductWithParameters(params, completionBlock: nil)
        self.presentViewController(vc, animated: true) { () -> Void in }*/
    }
    
    func likeUsOnFacebook() {
        let facebookURL = NSURL(string: "fb://profile/1054480257937006")!
        if UIApplication.sharedApplication().canOpenURL(facebookURL) {
            UIApplication.sharedApplication().openURL(facebookURL)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string:"https://www.facebook.com/catfactstexts/")!)
        }
        self.deselectSelectedIndexPath()
    }
    
    func followUsOnTwitter() {
        let twitterURL = NSURL(string: "twitter:///user?screen_name=catfacttext")!
        if UIApplication.sharedApplication().canOpenURL(twitterURL) {
            UIApplication.sharedApplication().openURL(twitterURL)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/catfacttext")!)
        }
        self.deselectSelectedIndexPath()
    }
    
    func privacyPolicy() {
        if let privacyVC =  self.storyboard?.instantiateViewControllerWithIdentifier("PrivacyPolicyVC") as? PrivacyPolicyVC {
            privacyVC.screenId = 0
            //let navController = UINavigationController(rootViewController: privacyVC)
            //self.presentViewController(navController, animated: true, completion: nil)
            self.navigationController?.pushViewController(privacyVC, animated: true)
        }
    }
    
    func termsOfService() {
        if let privacyVC =  self.storyboard?.instantiateViewControllerWithIdentifier("PrivacyPolicyVC") as? PrivacyPolicyVC {
            privacyVC.screenId = 1
            //let navController = UINavigationController(rootViewController: privacyVC)
            //self.presentViewController(navController, animated: true, completion: nil)
            self.navigationController?.pushViewController(privacyVC, animated: true)
        }
    }
    
    func visitOurWebsite() {
        if let website = NSURL(string: "https://www.catfactstexts.com/") {
            UIApplication.sharedApplication().openURL(website)
        }
        self.deselectSelectedIndexPath()
    }
    
    //MARK: - TableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (TableRow(row: indexPath.row)!) {
        case .RateUs:
            self.rateUs()
            break
        case .LikeUsOnFacebook:
            self.likeUsOnFacebook()
            break;
        case .FollowUsOnTwitter:
            self.followUsOnTwitter()
            break;
        case .PrivacyPolicy:
            self.privacyPolicy()
            break;
        case .TermsOfService:
            self.termsOfService()
            break;
        case .VisitOurWebsite:
            self.visitOurWebsite()
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
    
    func closeScreen() {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        self.versionNoLabel.text = "v" + versionNumber
        
        let closeBtn = UIBarButtonItem(image: UIImage(named: "closeBtn"), style: .Plain, target: self, action: "closeScreen")
        navigationItem.then {
            $0.leftBarButtonItem = closeBtn
        }
        
        self.navigationItem.title = "About"
        
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
