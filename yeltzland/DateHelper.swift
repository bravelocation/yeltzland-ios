//
//  DateHelper.swift
//  Yeltzland
//
//  Created by John Pollard on 16/08/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public class DateHelper {
    public static func dayNumber(_ date: Date) -> Int {
        // Removes the time components from a date
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.day, .month, .year]
        let startOfDayComponents = (calendar as NSCalendar).components(unitFlags, from: date)
        let startOfDay = calendar.date(from: startOfDayComponents)
        let intervalToStaryOfDay = startOfDay!.timeIntervalSince1970
        let daysDifference = floor(intervalToStaryOfDay) / 86400  // Number of seconds per day = 60 * 60 * 24 = 86400
        return Int(daysDifference)
    }
    
    public static func hourNumber(_ date: Date) -> Int {
        return Calendar.current.component(.hour, from: date)
    }
}
