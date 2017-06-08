//
//  SettingsVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/31/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    
    var containerViewController: SettingsTableVC?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }


    
    
    
    

    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)

    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embed segue" {
            let settingsTableVC = segue.destination as! SettingsTableVC
            containerViewController = settingsTableVC

            
        }
        
    }


}
