//
//  AppDelegate.swift
//  CatFacts
//
//  Created by Pae on 12/28/15.
//  Copyright © 2015 Pae. All rights reserved.
//

import UIKit
//import SVProgressHUD
import Firebase

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PFPush.handle(userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
                
        if GlobInfo.sharedInstance().objCurrentUser != nil {
            GlobInfo.sharedInstance().deviceTokenData = deviceToken;
            CatFactsApi.saveCurUserToInstallation()
        }
        else {
            GlobInfo.sharedInstance().deviceTokenData = deviceToken;
        }
    }
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        globalInit()
        UIApplication.shared.statusBarStyle = .lightContent
        
        let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        /*
        if let launchOptions = launchOptions as? [String : AnyObject] {
            if let notificationDictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                self.application(application, didReceiveRemoteNotification: notificationDictionary)
            }
        }*/
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - System Init
    
    func initParse() {
        
        ParseCrashReporting.enable();
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "cat-facts-parse"
            $0.clientKey = nil
            $0.server = "http://cat-facts-parse.herokuapp.com/parse/"
        }
        Parse.initialize(with: configuration)//*/
        //Parse.setApplicationId("EgwKnsH8rNRlvl6dcLoxZaJRe9GFjTtigLn3pKDV", clientKey: "QdEjGzitut8C5TbUXH00RQoZoAuA4Ch0u7WrBDtT")
        GlobInfo.sharedInstance();
        
        /*
        PFCloud.callFunctionInBackground("hello", withParameters: nil) { (object:AnyObject?, error:NSError?) in
            print("object:\(object!)")
            print("error:\(error?.description)")
        };*/
    }
    
    func gotoSignin() {
        
        let _storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let _vcRoot = _storyBoard.instantiateViewController(withIdentifier: "SignInVC")
        let _vcNav = UINavigationController(rootViewController: _vcRoot)
        
        _vcNav.interactivePopGestureRecognizer?.isEnabled = true
        _vcNav.interactivePopGestureRecognizer?.delegate = nil
        window?.rootViewController = _vcNav;
        
    }
    
    func gotoSignUp() {
        
        let _storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let _vcRoot = _storyBoard.instantiateViewController(withIdentifier: "SignUpVC")
        let _vcNav = UINavigationController(rootViewController: _vcRoot)
        
        _vcNav.interactivePopGestureRecognizer?.isEnabled = true
        _vcNav.interactivePopGestureRecognizer?.delegate = nil
        window?.rootViewController = _vcNav
    }
    
    func gotoMain() {
        
        CatFactsApi.reqMyContactCount(nil) { (succeed, count) -> Void in
            
            if (succeed == true) {
                
                let _storyBoard = UIStoryboard(name: "Main", bundle: nil)
                var _viewMain:UIViewController?
                
                if (count > 0) {
                    _viewMain = _storyBoard.instantiateViewController(withIdentifier: "ContactsVC")
                } else {
                    _viewMain = _storyBoard.instantiateViewController(withIdentifier: "AddContactVC")
                }
                
                //- (id)initWithRearViewController:(UIViewController *)rearViewController frontViewController:(UIViewController *)frontViewController;

                var _viewNav:UINavigationController?
                
                
                _viewNav = UINavigationController(rootViewController: _viewMain!)
                /*
                if let _viewNav = self.window?.rootViewController as? UINavigationController {
                    _viewNav.setViewControllers([_viewMain!], animated: true)
                } else {
                    _viewNav = UINavigationController(rootViewController: _viewMain!)
                    //self.window?.rootViewController = _viewNav
                }*/
                
                _viewNav?.interactivePopGestureRecognizer?.isEnabled = true
                _viewNav?.interactivePopGestureRecognizer?.delegate = nil
                
                
                let menuVC = _storyBoard.instantiateViewController(withIdentifier: "MenuVC")
                let menuNavController = UINavigationController(rootViewController: menuVC)
                
                let mainRevealController:SWRevealViewController = SWRevealViewController(rearViewController: menuNavController, frontViewController: _viewNav)
                self.window?.rootViewController = mainRevealController
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func globalInit() {
        
        self.initParse()
        self.initAppearance()
        self.startApp()
    }
    
    func initAppearance() {
        
        SVProgressHUD.setBackgroundColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.white)
        //SVProgressHUD.setInfoImage(UIImage())
        SVProgressHUD.setFont(UIFont.systemFont(ofSize: 13.0))
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 63/255.0, green: 157/255.0, blue: 217/255.0, alpha: 1.0)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont(name: "Helvetica Neue", size: 20.0)!]
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    func startApp() {
        
        if (GlobInfo.sharedInstance().isLoggedIn() == true) {
            self.gotoMain()
        } else {
            self.gotoSignin()
        }
    }
}

        
        
        
        
        
        


