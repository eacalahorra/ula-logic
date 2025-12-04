//
//  DayEntry.swift
//  ULA Period Tracker
//  Handles basic Day to Day Reporting.
//  Created by eacalahorra.
//

import Foundation

struct DayEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var bleeding: Int // 0 to 4 , none to heavy...
    var symptoms: [String]
    var notes: String?
    var isPeriodStart: Bool
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        bleeding: Int = 0,
        symptoms: [String] = [],
        notes: String? = nil,
        isPeriodStart: Bool = false
    ) {
        let cal = Calendar.current
        self.id = id
        self.date = cal.startOfDay(for: date)
        self.bleeding = bleeding
        self.symptoms = symptoms
        self.notes = notes
        self.isPeriodStart = isPeriodStart
    }
}
