//
//  ULASchemaWrapper.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

struct ULASchemaWrapper: Codable {
    let schemaVersion: Int
    let appVersion: String
    let entries: [DayEntry]
    let sexEvents: [SexEvent]
    let symptoms: [Symptom]?
    let hasCompletedOnboarding: Bool
    let isRegularUser: Bool
    let onboardingLastPeriodEnd: Date?
}
