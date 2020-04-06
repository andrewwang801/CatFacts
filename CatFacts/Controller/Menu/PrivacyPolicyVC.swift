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

        let closeBtn = UIBarButtonItem(image: UIImage(named: "closeBtn"), style: .plain, target: self, action: #selector(PrivacyPolicyVC.closeScreen))
        navigationItem.leftBarButtonItem = closeBtn

        var titleStr:String = "", fileName:String = ""
        if screenId == 0 {
            titleStr = "Privacy Policy";
            fileName = "CatFactsPrivacyPolicy";
        }
        else if screenId == 1 {
            titleStr = "Terms of Service";
            fileName = "CatFactsTermsOfService";
        }
        else if screenId == 2 {
            titleStr = "About";
            fileName = "CatFactsAbout";
        }
        else if screenId == 3 {
            titleStr = "Help";
            fileName = "CatFactsHelp";
        }
        else if screenId == 4 {
            titleStr = "FAQ";
            fileName = "CatFactsFAQ";
        }

        self.navigationItem.title = titleStr

        self.textView.text = ""

        let rtf = Bundle.main.url(forResource: fileName, withExtension: "rtf", subdirectory: nil, localization: nil)
        let attributedString : NSMutableAttributedString
        do {
            try attributedString = NSMutableAttributedString(fileURL: rtf!, options: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtf], documentAttributes: nil)
        }
        catch {
            attributedString = NSMutableAttributedString(string: "")
        }
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17.0), range: NSMakeRange(0, attributedString.length))

        self.textView.attributedText = attributedString
        self.textView.contentOffset = CGPoint.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func closeScreen() {
        self.navigationController?.dismiss(animated: true, completion:nil)
    }
}
