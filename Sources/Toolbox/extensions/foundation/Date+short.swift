//
//  Date+short.swift
//
//
//  Created .
//  Copyright © 2021 . All rights reserved.
//

import Foundation

public extension Date {
    
    func laterString(from: Date) -> String {
        let currentDate = from
        let date = self
        let calendar = Calendar.current
        let components: DateComponents = calendar.dateComponents(
            [.year, .month, .weekOfMonth, .day, .hour, .minute],
            from: currentDate,
            to: date)
        
        if components.year == 0 {
            // same year
            if components.month == 0 {
                // same month
                if components.weekOfMonth == 0 {
                    // same week
                    if components.day == 0 {
                        // same day
                        if components.hour == 0 {
                            // same hour
                            return (components.minute ?? 0).countableString(withSingularNoun: "minute")
                            
                        } else {
                            // different hour
                            return (components.hour ?? 0).countableString(withSingularNoun: "hour")
                        }
                    } else {
                        // different day
                        return (components.day ?? 0).countableString(withSingularNoun: "day")
                    }
                } else {
                    // different week
                    return (components.weekOfMonth ?? 0).countableString(withSingularNoun: "week")
                }
            } else {
                // different month
                return (components.month ?? 0).countableString(withSingularNoun: "month")
            }
        } else {
            // different year
            return (components.year ?? 0).countableString(withSingularNoun: "year")
        }
    }
    
}
