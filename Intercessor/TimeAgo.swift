//
//  TimeAgo.swift
//  Odio
//
//  Created by Xavier Sharp on 12/15/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

let kMinute = 60
let kDay = kMinute * 24
let kWeek = kDay * 7
let kMonth = kDay * 31
let kYear = kDay * 365

func timeAgoSinceDateCompact(_ date:Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    
    let components:DateComponents = (calendar as NSCalendar).components([.minute, .hour, .day, .weekOfYear, .second], from: earliest, to: latest, options: [])
    
    if (components.weekOfYear! >= 1) {
        return "\(components.weekOfYear!)w"
    } else if (components.day! >= 1) {
        return "\(components.day!)d"
    } else if (components.hour! >= 1) {
        return "\(components.hour!)h"
    } else if (components.minute! >= 1) {
        return "\(components.minute!)m"
    } else if (components.second! >= 3) {
        return "\(components.second!)s"
    } else {
        return "now"
    }
    
}

func timeAgoSinceDate(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    
    let components:DateComponents = (calendar as NSCalendar).components([.minute, .hour, .day, .weekOfYear, .month, .year, .second], from: earliest, to: latest, options: [])
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now"
    }
}

func relativeDate(_ date:Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    
    let components:DateComponents = (calendar as NSCalendar).components([.day, .weekOfYear, .month, .year], from: earliest, to: latest, options: [])
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1) {
        return "\(components.year!) year ago"
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1) {
        return "\(components.month!) month ago"
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1) {
        return "\(components.weekOfYear!) week ago"
    } else if (components.day! > 0) {
        if (components.day! > 1) {
            return "\(components.day!) days ago"
        } else {
            return "Yesterday"
        }
    } else {
        return "Today"
    }
}
