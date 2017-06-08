//
//  SendToTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol SendToDelegate {
    func checkButtonTappedAdd(_ indexPath: IndexPath)
}


class SendToTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var delegate: SendToDelegate!
    var index: IndexPath!
    
    var isChecked: Bool = false {
        didSet {
            checkButton.isSelected = isChecked
            if checkButton.isSelected {
                titleLabel.font = UIFont(name:"Avenir-Bold", size: 17.0)
            } else {
                titleLabel.font = UIFont(name:"Avenir", size: 17.0)
            }
        }
    }
    
    var group: Group! {
        didSet {
            self.titleLabel.text = group.name
        }
    }
    var friend: User! {
        didSet {
            self.titleLabel.text = friend.displayName
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func checkButtonTapped(_ sender: AnyObject) {
        delegate.checkButtonTappedAdd(index)
    }

}
