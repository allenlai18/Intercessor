//
//  Push.swift
//  Intercessor
//
//  Created by Allen Lai on 12/3/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import OneSignal

open class Push {

    static func SendPushNotification(message: String, userIds: [String]) {
        OneSignal.postNotification(["contents": ["en": message], "include_player_ids": userIds])
    }

}
