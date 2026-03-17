//
//  ULASchemaWrapper.swift
//  ULA Period Tracker
//
//  Created by eacalahorra on 19/11/25.
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
    let onboardingLastPeriodStart: Date?

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case appVersion
        case entries
        case sexEvents
        case symptoms
        case hasCompletedOnboarding
        case isRegularUser
        case onboardingLastPeriodStart
        case onboardingLastPeriodEnd
    }

    init(
        schemaVersion: Int,
        appVersion: String,
        entries: [DayEntry],
        sexEvents: [SexEvent],
        symptoms: [Symptom]?,
        hasCompletedOnboarding: Bool,
        isRegularUser: Bool,
        onboardingLastPeriodStart: Date?
    ) {
        self.schemaVersion = schemaVersion
        self.appVersion = appVersion
        self.entries = entries
        self.sexEvents = sexEvents
        self.symptoms = symptoms
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isRegularUser = isRegularUser
        self.onboardingLastPeriodStart = onboardingLastPeriodStart
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        appVersion = try container.decode(String.self, forKey: .appVersion)
        entries = try container.decode([DayEntry].self, forKey: .entries)
        sexEvents = try container.decode([SexEvent].self, forKey: .sexEvents)
        symptoms = try container.decodeIfPresent([Symptom].self, forKey: .symptoms)
        hasCompletedOnboarding = try container.decode(Bool.self, forKey: .hasCompletedOnboarding)
        isRegularUser = try container.decode(Bool.self, forKey: .isRegularUser)
        let start = try container.decodeIfPresent(Date.self, forKey: .onboardingLastPeriodStart)
        let legacyEnd = try container.decodeIfPresent(Date.self, forKey: .onboardingLastPeriodEnd)
        onboardingLastPeriodStart = start ?? legacyEnd
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(entries, forKey: .entries)
        try container.encode(sexEvents, forKey: .sexEvents)
        try container.encodeIfPresent(symptoms, forKey: .symptoms)
        try container.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try container.encode(isRegularUser, forKey: .isRegularUser)
        try container.encodeIfPresent(onboardingLastPeriodStart, forKey: .onboardingLastPeriodStart)
    }
}
