//
//  ConversationHistoryVC.swift
//  CatFacts
//
//  Created by DevGuru on 3/17/17.
//  Copyright © 2017 Pae. All rights reserved.
//

import UIKit

class ConversationHistoryVC: CFBaseVC, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblConversations: UITableView!

    var theContact:PFObject?
    var arrConversations:NSMutableArray?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Conversation History";
        
        self.tblConversations.estimatedRowHeight = 40
        self.tblConversations.rowHeight = UITableViewAutomaticDimension
        
        self.loadConversationData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadConversationData() {
        
        arrConversations = NSMutableArray()
        
        CatFactsApi.reqConversationHistory(nil, contact: theContact) { (succeed, aArrResult) -> Void in
            if (succeed) {
                self.arrConversations!.addObjectsFromArray(aArrResult! as [AnyObject])
                self.refreshList()
            }
        }
    }
    
    func refreshList() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tblConversations.reloadData()
        })
        
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return (arrConversations?.count)!
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let _cellSet:UITableViewCell = tblConversations.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath)
        
        let _objConversation = arrConversations![indexPath.row] as! PFObject
        let message:String = _objConversation["message"] as? String ?? ""
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_GB")

        let date: String = dateFormatter.stringFromDate(_objConversation.createdAt!)
        
        _cellSet.textLabel?.text = message
        _cellSet.detailTextLabel?.text = date
        
        return _cellSet
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
