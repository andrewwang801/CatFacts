//
//  PrivacyPolicyVC.swift
//  CatFacts
//
//  Created by Work on 15/04/2016.
//  Copyright © 2016 Pae. All rights reserved.
//

import UIKit


class PrivacyPolicyVC: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var screenId:Int = 0
    
    /*
    func closeScreen() {
        self.dismissViewControllerAnimated(true, completion:nil)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let closeBtn = UIBarButtonItem(image: UIImage(named: "closeBtn"), style: .Plain, target: self, action: "closeScreen")
        navigationItem.then {
            $0.leftBarButtonItem = closeBtn
        }*/
        
        var titleStr:String = "", fileName:String = ""
        if(screenId == 0) {
            titleStr = "Privacy Policy";
            fileName = "CatFactsPrivacyPolicy";
        }
        else {
            titleStr = "Terms of Service";
            fileName = "CatFactsTermsOfService";
        }
        
        self.navigationItem.title = titleStr
        
        self.textView.text = ""
        
        let rtf = NSBundle.mainBundle().URLForResource(fileName, withExtension: "rtf", subdirectory: nil, localization: nil)
        let attributedString : NSMutableAttributedString
        do {
            try attributedString = NSMutableAttributedString(fileURL: rtf!, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
        }
        catch {
            attributedString = NSMutableAttributedString(string: "")
        }
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(17.0), range: NSMakeRange(0, attributedString.length))
        
        self.textView.attributedText = attributedString
        self.textView.contentOffset = CGPointZero
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
