//
//  DiscoverVC.swift
//  Intercessor
//
//  Created by Allen Lai on 9/26/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import Firebase

class DiscoverVC: UIViewController {

    var hashtags: [String]    = []
    var users: [User]       = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAnalytics.logEvent(withName: "Discover_Page", parameters: nil)

        
        let nc = NotificationCenter.default
        Discover.getFeaturedHashTags { (hashtags) in
            self.hashtags = hashtags
            
            nc.post(name: NSNotification.Name(rawValue: kNotifFeaturedTagsLoaded), object: nil)
        }
        Discover.getFeaturedUsers { (usersFound) in
            self.users = usersFound as! [User]
            
            nc.post(name: NSNotification.Name(rawValue: kNotifFeaturedUsersLoaded), object: nil)
        }
    
    }

    
    @IBAction func backButtonTapped(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hashtagSegue    = "embedHashtag"
        let profileSegue    = "embedProfile"
        
        guard let identifier = segue.identifier  else {
            return
        }
        
        if identifier.contains(hashtagSegue) {
            let vc = segue.destination as! FeaturedHashtagViewController
            vc.parentVC = self
            
            switch identifier {
            case "\(hashtagSegue)1":
                vc.index = 0
            case "\(hashtagSegue)2":
                vc.index = 1
            case "\(hashtagSegue)3":
                vc.index = 2
            case "\(hashtagSegue)4":
                vc.index = 3
            case "\(hashtagSegue)5":
                vc.index = 4
            case "\(hashtagSegue)6":
                vc.index = 5
            default:
                break
            }
        }
        
        if identifier.contains(profileSegue) {
            let vc = segue.destination as! FeaturedUserViewController
            vc.parentVC = self
            
            switch identifier {
            case "\(profileSegue)1":
                vc.index = 0
            case "\(profileSegue)2":
                vc.index = 1
            case "\(profileSegue)3":
                vc.index = 2
            case "\(profileSegue)4":
                vc.index = 3
            default:
                break
            }
        }
        
        if identifier == "hashtagSegue" {
            let hashtag = sender as! String
            let vc = segue.destination as! HashTagVC
            vc.hashTagString = hashtag
        }
        
    }



    
    func showProfile(_ friend: User) {
        Segues.showProfile(user: friend, navigationController: self.navigationController!)
    }
    
}
