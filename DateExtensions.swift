//
//  DateExtensions.swift
//  AmusementParkPart1
//
//  Created by redBred LLC on 11/16/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

extension Date {
    
    // quickly calculates the seconds inthe number of years specified
    static func getTimeInterval(numberOfYears: Int) -> TimeInterval {
        return TimeInterval(60*60*24*365.2422*Double(numberOfYears))
    }
    
    // quickly construct a date object using the components specified
    static func getDate(year: Int, month: Int, Day: Int) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = Day
        
        return calendar.date(from: components)
    }
    
    static func getDateFromStringMM_DD_YYYY(stringDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: stringDate)
        return date
    }

    static func getDateFromStringYYYY_MM_DD(stringDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: stringDate)
        return date
    }
    
    static func currentYear() -> Int {
        let calendar = Calendar.current

        return calendar.component(.year, from: Date())
    }
    
    var year: Int {
        let calendar = Calendar.current
        
        return calendar.component(.year, from: self)
    }
}
