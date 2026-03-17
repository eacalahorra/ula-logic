//
//  SexEvent.swift
//  ULA Period tracker
//
//  Created by eacalahorra on 18/11/25.
//

import Foundation

struct SexEvent: Identifiable, Codable {
    let id: UUID
    let date: Date
    var protected: Bool?
    var notes: String?
}
