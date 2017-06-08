//
//  HashtagCell.swift
//  Odio
//
//  Created by Xavier Sharp on 12/28/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

import UIKit

class HashtagCell: UITableViewCell {
    
    var parentVC: SearchViewController!
    var lowerStr: String!
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    
    @IBAction func tagTapped(_ sender: UIButton) {
        Segues.goToHashTag(tagString: lowerStr, navigationController: parentVC.navigationController!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadData(tag: String)
    {
//        guard let tag = object.objectForKey(kHashtagTag) as? String else {
//            tagButton.isUserInteractionEnabled = false
//            return
//        }
        
        lowerStr = tag.lowercased()
        tagLabel.text = tag.uppercased()
    }

}
