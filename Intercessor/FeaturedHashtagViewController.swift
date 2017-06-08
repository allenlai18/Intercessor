//
//  FeaturedHashtagViewController.swift
//  Odio
//
//  Created by Xavier Sharp on 12/28/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

import UIKit

class FeaturedHashtagViewController: UIViewController {
    
    var parentVC: DiscoverVC!
    var hashTag: String!
    var lowerStr: String!
    var index: Int!

    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var hashtagButton: UIButton!
    
    @IBAction func hashtagTapped(_ sender: AnyObject) {
        Segues.goToHashTag(tagString: lowerStr, navigationController: parentVC.navigationController!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isHidden = true
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.update), name: NSNotification.Name(rawValue: kNotifFeaturedTagsLoaded), object: nil)
        
    }
    func update() {
        hashTag = parentVC.hashtags[index]
        loadData()
    }
    func loadData() {
        guard let _ = hashTag as String? else {
            hashtagButton.isUserInteractionEnabled = false
            return
        }
        
        hashtagButton.isUserInteractionEnabled = true
        
        self.lowerStr = hashTag.lowercased()
        
        
        DispatchQueue.main.async(execute: {
            self.view.isHidden = false
            self.hashtagLabel.text = "#" + self.hashTag.uppercased()
        })

    
    }
    


}
