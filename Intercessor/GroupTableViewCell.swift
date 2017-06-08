//
//  GroupTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupTitle: UILabel!
    
    var cellGroup: Group! {
        didSet {
            groupImageView.loadImageUsingCacheWithUrlString(cellGroup.groupPicURL)
            groupTitle.text = cellGroup.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.groupImageView.layer.cornerRadius = 20
        self.groupImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
