//
//  MonthBuilder.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

struct MonthDay: Identifiable {
    let id = UUID()
    let date: Date?
}

struct MonthBuilder {
    private static let calendar = Calendar.current
    
    static func buildMonth(for date: Date) -> [MonthDay] {
        let cal = calendar
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: date)),
              let range = cal.range(of: .day, in: .month, for: monthStart)
        else {
            return []
        }
        
        // Determine what weekday the first day falls on
        let firstWeekday = cal.component(.weekday, from: monthStart)
                
        // Create leading blanks
        let leading = (firstWeekday - cal.firstWeekday + 7) % 7
                
        var days: [MonthDay] = []
                
        // Add blanks
        for _ in 0..<leading {
            days.append(MonthDay(date: nil))
        }
                
        // Add actual days
        for day in range {
            if let realDate = cal.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(MonthDay(date: realDate))
            }
        }
                
        
        while days.count % 7 != 0 {
            days.append(MonthDay(date: nil))
        }
                
        return days
    }
}
