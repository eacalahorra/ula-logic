//
//  Cycle.swift
//  ULA Period Tracker
//
//  Created by eacalahorra on 18/11/25.
//

import Foundation

struct Cycle: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    
    var length: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
