//
//  EmptyCell.swift
//  Odio
//
//  Created by Xavier Sharp on 1/13/16.
//  Copyright © 2016 XQ Creative, LLC. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    
    func loadText(type: String)
    {
        var text = ""
        switch type
        {
            case kSearchTypeUsers:
                text = "No Users Found"
                break
            case kSearchTypeHashtags:
                text = "No Hashtags Found"
                break
            default:
                break
        }
        
        tagLabel.text = text
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
