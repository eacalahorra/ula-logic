//
//  Symptom.swift
//  ULA Period Tracker.
//
//  Created by eacalahorra.
//

import Foundation

struct Symptom: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let type: SymptomType
    let intensity: Int?
    let note: String?
}
