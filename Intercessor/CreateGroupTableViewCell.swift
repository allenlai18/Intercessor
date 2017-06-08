//
//  CreateGroupTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/27/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

protocol CreateGroupDelegate {
    func checkButtonTappedAdd(_ indexPath: IndexPath)
}


class CreateGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var delegate: CreateGroupDelegate!
    var index: IndexPath!
    
    var isChecked: Bool = false {
        didSet {
            checkButton.isSelected = isChecked
            if checkButton.isSelected {
                displayNameLabel.font = UIFont(name:"Avenir-Bold", size: 17.0)
            } else {
                displayNameLabel.font = UIFont(name:"Avenir", size: 17.0)
            }
        }
    }
    
    var friendUser: User! {
        didSet {
            displayNameLabel.text = friendUser.displayName
            self.profileImageView.loadImageUsingCacheWithUrlString(friendUser.profilePicURL)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // make profileImage rounded
        self.profileImageView.layer.cornerRadius = 30/2
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        checkButton.isSelected = false
        
    }

    
    @IBAction func checkButtonTapped(_ sender: AnyObject) {
        delegate.checkButtonTappedAdd(index)
    }
    
    
}




