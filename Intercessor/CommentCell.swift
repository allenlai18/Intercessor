//
//  CommentCell.swift
//  Odio
//
//  Created by Xavier Sharp on 12/30/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var content: UILabel!
    
    // get the username for usernameStr

    
    var comment: Comment! {
        didSet {

            let commentText = comment.content
            AllFriendsRepo.sharedInstance.fetchUser(userID: comment.userID) { (userFound) in
                let boldAttributes : [String : AnyObject] = [
                    NSFontAttributeName: UIFont.init(name: "Lato-Bold", size: 13.0)!,
                    NSForegroundColorAttributeName: UIColor.white
                ]
                let normAttributes : [String : AnyObject] = [
                    NSFontAttributeName: UIFont.init(name: "Lato-Light", size: 13.0)!,
                    NSForegroundColorAttributeName: UIColor.white
                ]
                
                let usernameStr = NSMutableAttributedString(string: userFound.username, attributes: boldAttributes)
                let contentStr  = NSMutableAttributedString(string: String(" " + commentText), attributes: normAttributes)
                
                usernameStr.append(contentStr)
                
                self.content.attributedText = usernameStr
            }
            
            

            

        }
    }
    
    
}




