//
//  TabBarController.swift
//  Intercessor
//
//  Created by Allen Lai on 11/4/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.tabBar.tintColor = UIColor.hex("#6F6F6F", alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // you can set the title of the VC in storyboard or in code. But basically, just have a way to differentiate
        // and see which view controller you're about to present
        if let title = viewController.title {
            if title == "Add Post" {
                tabBarController.performSegue(withIdentifier: "Add Post", sender: nil)
                return false
            } else {
                return true
            }
        }
        return true
        
    }

    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            if let naviController = viewController as? UINavigationController {
                if let vc = naviController.topViewController as? HomeVC {
                    vc.scrollToTop()
                }
            }
        }
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
