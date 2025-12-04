//
//  SymptomType.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

enum SymptomType: String, Codable, CaseIterable, Hashable {
    case cramps
    case bloating
    case headache
    case backPain
    case tenderBreasts
    case fatigue
    case moodSwing
    case cravings
    case nausea
    case acne
    case insomnia
    case diarrhea
    case constipation
    case ovulationPain // Mittelschmerz... idk if this is common, I do not have a Uterus... :/
    case other
}
