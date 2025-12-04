//
//  PeriodEpisode.swift
//  ULA Period Tracker
//  Refers to Period Prediction ±
//  Created by eacalahorra.
//

import Foundation

struct PeriodEpisode: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let days: [DayEntry]
    
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
