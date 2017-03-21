//
//  ConversationHistoryVC.swift
//  CatFacts
//
//  Created by DevGuru on 3/20/17.
//  Copyright © 2017 Pae. All rights reserved.
//

import UIKit

class ConversationHistoryVC: JSQMessagesViewController {
    var theContact:PFObject?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Conversation History";
        self.inputToolbar.hidden = true
        self.loadConversationData()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource? {
        let message = messages[indexPath.item]
        if message.senderId == "Contact" {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let contactName:String = theContact!["name"] as? String ?? ""
        
        let message = messages[indexPath.item]
        if message.senderId == "Server" {
            cell.textView?.textColor = UIColor.blackColor()
            
            cell.avatarImageView?.image = self.contactImageWithContactInformation("")
        } else {
            cell.textView?.textColor = UIColor.whiteColor()
            
            let imageFile = theContact!["profilePicture"] as? PFFile
            
            if imageFile != nil {
                imageFile!.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        let image = UIImage(data: imageData!)
                        cell.avatarImageView?.image = image
                    }
                    else {
                        cell.avatarImageView?.image = self.contactImageWithContactInformation(contactName)
                    }
                })
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func senderId() -> String {
        return "Contact"
    }
    
    override func senderDisplayName() -> String {
        return "Contact"
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = self.messages[indexPath.item]
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault + 20
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func loadConversationData() {
        CatFactsApi.reqConversationHistory(nil, contact: theContact) { (succeed, aArrResult) -> Void in
            if (succeed) {
                for i in 0...aArrResult!.count - 1 {
                    let conversationObj = aArrResult![i] as! PFObject
                    var senderId = ""
                    if conversationObj["isContactResponse"] as! Bool  == true {
                        senderId = "Contact"
                    } else {
                        senderId = "Server"
                    }
                    
                    let displayName = "Contact"
                    let messageContent = conversationObj["message"] as! String
                    let date = conversationObj.createdAt!
                    let message = JSQMessage(senderId: senderId, senderDisplayName: displayName, date: date, text: messageContent)
                    self.messages += [message]
                }
                
                self.reloadMessageView()
            }
        }
    }
    
    func reloadMessageView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
        })
    }
    
    func contactImageWithContactInformation(name:String) -> UIImage? {
        
        let width:CGFloat = 42
        let height:CGFloat = 42
        
        // Find the middle of the circle
        let center = CGPointMake(width/2.0, height/2.0)
        
        var startAngle: Float = Float(2 * M_PI)
        var endAngle: Float = 0.0
        
        // Drawing code
        // Set the radius
        let strokeWidth = 0
        let radius = width/2.0
        
        let strokeColor = UIColor.lightGrayColor()
        let fillColor = UIColor.lightGrayColor()
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, UIScreen.mainScreen().scale)
        
        var context = UIGraphicsGetCurrentContext()
        
        // Set the stroke color
        CGContextSetStrokeColorWithColor(context!, strokeColor.CGColor)
        
        // Set the line width
        CGContextSetLineWidth(context!, CGFloat(strokeWidth))
        
        // Set the fill color (if you are filling the circle)
        CGContextSetFillColorWithColor(context!, fillColor.CGColor)
        
        startAngle = startAngle - Float(M_PI_2)
        endAngle = endAngle - Float(M_PI_2)
        
        // Draw the arc around the circle
        CGContextAddArc(context!, center.x, center.y, CGFloat(radius), CGFloat(startAngle), CGFloat(endAngle), 0)
        
        // Draw the arc
        CGContextDrawPath(context!, .FillStroke)
        
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        var firstName = "", lastName = ""
        
        let array = name.characters.split(" ").map { String($0) }
        if array.count >= 2 {
            firstName = array[0]
            lastName = array[1]
        }
        else {
            firstName = name
            lastName = ""
        }
        
        let firstInitial = firstName.characters.count > 0 ? firstName.substringToIndex(firstName.startIndex.advancedBy(1)) : ""
        let lastInitial = lastName.characters.count > 0 ? lastName.substringToIndex(lastName.startIndex.advancedBy(1)) : ""
        let initials:NSString = (firstInitial + lastInitial).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, UIScreen.mainScreen().scale)
        context = UIGraphicsGetCurrentContext()
        
        CGContextDrawImage(context!, CGRectMake(0, 0, width, height), (circularImage?.CGImage)!)
        
        let textColor = UIColor.whiteColor()
        let textFont = UIFont.systemFontOfSize(20)
        let attributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : textFont]
        let size = initials.sizeWithAttributes(attributes)
        initials.drawAtPoint(CGPointMake(center.x-size.width/2.0, center.y-size.height/2.0), withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
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
