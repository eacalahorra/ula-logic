//
//  UserSettings.swift
//  ULA - Period Tracking App
//
//  Created by eacalahorra on 18/11/25.
//

import Foundation

struct UserSettings: Codable {
    var cycleLengthOverride: Int?
    var irregularUser: Bool = false
}
