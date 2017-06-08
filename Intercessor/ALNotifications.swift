//
//  ALNotifications.swift
//  Intercessor
//
//  Created by Allen Lai on 11/12/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import LNRSimpleNotifications


open class ALNotification {
    
    let manager = LNRNotificationManager()
    
    init() {
        manager.notificationsPosition = LNRNotificationPosition.top
        manager.notificationsTitleTextColor     = UIColor.white
        manager.notificationsBodyTextColor      = UIColor.white
        manager.notificationsTitleFont          = UIFont(name: "Lato-Bold", size: 14.0)!
        manager.notificationsBodyFont           = UIFont(name: "Lato-Regular", size: 13.0)!
    }
    
    
    func error(_ title: String?, message: String) {
        var t = title
        if t == nil { t = "Error" }
        
        let icon = UIImage(named: "notificaton-icon-error.png")
        
        manager.notificationsBackgroundColor    = UIColor.hex("#D0021B", alpha: 1.0)
        manager.notificationsSeperatorColor     = UIColor.hex("#D0021B", alpha: 1.0)
        manager.notificationsIcon               = icon
        
        manager.showNotification(title: t!, body: message) { _ in
            let _ = self.manager.dismissActiveNotification(completion: { _ in
                print("ALNotification.swift - Error dismissed")
            })
        }
    }
    
    func success(_ title: String?, message: String) {
        var t = title
        if t == nil { t = "Success" }
        
        let icon = UIImage(named: "notificaton-icon-success.png")
        
        manager.notificationsIcon               = icon
        manager.notificationsBackgroundColor    = UIColor.hex("#7ED321", alpha: 1.0)
        manager.notificationsSeperatorColor     = UIColor.hex("#7ED321", alpha: 1.0)
        
        manager.showNotification(title: t!, body: message) { _ in
            let _ = self.manager.dismissActiveNotification(completion: { _ in
                print("ALNotification.swift - Success dismissed")
            })
        }
        
    }
}
