//
//  SDISRequest.swift
//  ULA Period Tracker
//  SDIS is the Standard Dialog Sheet. This allows us to call it no matter where it is and makes it non-exclusive to the TodayView.
//  Created by eacalahorra.
//

import Foundation

enum DayAction: Identifiable {
    case startPeriod
    case logBleeding
    case logSex
    case logSymptoms
    case editBleeding
    case editSex
    case editSymptoms

    var id: String {
        switch self {
        case .startPeriod: return "startPeriod"
        case .logBleeding: return "logBleeding"
        case .logSex: return "logSex"
        case .logSymptoms: return "logSymptoms"
        case .editBleeding: return "editBleeding"
        case .editSex: return "editSex"
        case .editSymptoms: return "editSymptoms"
        }
    }
}

struct SDISRequest: Identifiable {
    let id = UUID()
    let action: DayAction
    let date: Date
}
