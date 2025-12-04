//
//  UserSettings.swift
//  ULA - Period Tracking App
//
//  Created by eacalahorra.
//

import Foundation

struct UserSettings: Codable {
    var cycleLengthOverride: Int?
    var irregularUser: Bool = false
}
