//
//  Symptom.swift
//  ULA Period Tracker.
//
//  Created by eacalahorra on 21/11/25.
//

import Foundation

struct Symptom: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let type: SymptomType
    let intensity: Int?
    let note: String?
}
