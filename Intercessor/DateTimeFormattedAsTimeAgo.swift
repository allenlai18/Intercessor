//
//  DateTimeFormattedAsTimeAgo.swift
//  Swift Time Ago
//
//  Created by Julien Colin on 4/17/15.
//  Copyright (c) 2015 Toldino. All rights reserved.
//

import Foundation

public func dateTimeFormattedAsTimeAgo(_ date: Date, referenceDate now: Date = Date()) -> String {
    
    let secondsFromDate = now.secondsFrom(date)
    if secondsFromDate < 60 {
        return secondsFormatter()
    }
    
    let minutesFromDate = now.minutesFrom(date)
    if minutesFromDate < 60 {
        return minutesFormatter(minutesFromDate)
    }
    
    let hoursFromDate = now.hoursFrom(date)
    if hoursFromDate < 24 {
        return hoursFormatter(hoursFromDate)
    }
    
    let daysFromDate = now.daysFrom(date)
    switch daysFromDate {
    case 1:
        return yesterdayFormatter()
    case 2...6:
        return daysFormatter(daysFromDate)
    default:
        break
    }
    
    let format = DateFormatter()
    format.dateFormat = "MM/dd/yy"

    return format.string(from: date)
    
//    let weeksFromDate = now.weeksFrom(date)
//    let monthsFromDate = now.monthsFrom(date)
//    switch monthsFromDate {
//    case 0:
//        return weeksFormatter(weeksFromDate)
//    case 1...11:
//        return monthsFormatter(monthsFromDate)
//    default:
//        break
//    }
//    
//    let yearsFromDate = now.yearsFrom(date)
//    return yearsFormatter(yearsFromDate)
}

// MARK: Formatter functions

func classicFormatterAgo(_ quantity: Int, unit: String) -> String {
    var formattedString = "\(quantity) \(unit)"
    if quantity > 1 {
        formattedString += "s"
    }
    formattedString += " ago"
    return formattedString
}

func secondsFormatter() -> String {
    return "Just now"
}

func minutesFormatter(_ minutes: Int) -> String {
    return classicFormatterAgo(minutes, unit: "minute")
}

func hoursFormatter(_ hours: Int) -> String {
    return classicFormatterAgo(hours, unit: "hour")
}

func yesterdayFormatter() -> String {
    return "Yesterday"
}

func daysFormatter(_ days: Int) -> String {
    return classicFormatterAgo(days, unit: "day")
}

func weeksFormatter(_ weeks: Int) -> String {
    return classicFormatterAgo(weeks, unit: "week")
}

func monthsFormatter(_ months: Int) -> String {
    return classicFormatterAgo(months, unit: "month")
}

func yearsFormatter(_ years: Int) -> String {
    return classicFormatterAgo(years, unit: "year")
}

// MARK: Extension of NSDate

private extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.second, from: date, to: self, options: []).second!
    }
}
