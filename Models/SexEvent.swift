//
//  SexEvent.swift
//  ULA Period tracker
//
//  Created by eacalahorra.
//

import Foundation

struct SexEvent: Identifiable, Codable {
    let id: UUID
    let date: Date
    var protected: Bool?
    var notes: String?
}
