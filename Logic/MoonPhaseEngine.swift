//
//  MoonPhaseEngine.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//  Tracks MoonPhases via Math, correlating to the Calendar. It is a fun addition. 
// --- CURRENTLY UNUSED ---

import Foundation

enum MoonPhase: String, Codable {
    case newMoon
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case fullMoon
    case waningGibbous
    case lastQuarter
    case waningCrescent
}

struct MoonPhaseEngine {
    private let calendar = Calendar.current
    
    func phase(for date: Date) -> MoonPhase {
        let synodicMonth = 29.53058867
        
        var comps = DateComponents()
        comps.year = 2000 //refers to the new moon on the 6th of January, 2000.
        comps.month = 1
        comps.day = 6
        comps.hour = 18
        comps.minute = 14
        
        let base = calendar.date(from: comps)!
        let secondsSince = date.timeIntervalSince(base)
        let daysSince = secondsSince / 86400.0
        let phase = (daysSince.truncatingRemainder(dividingBy: synodicMonth) + synodicMonth)
            .truncatingRemainder(dividingBy: synodicMonth)
        let normalized = phase / synodicMonth
        
        switch normalized {
        case 0.00..<0.03, 0.97...1.00:
            return.newMoon
        case 0.03..<0.22:
            return .waxingCrescent
        case 0.22..<0.28:
            return .firstQuarter
        case 0.28..<0.47:
            return .waxingGibbous
        case 0.47..<0.53:
            return .fullMoon
        case 0.53..<0.72:
            return .waningGibbous
        case 0.72..<0.78:
            return .lastQuarter
        default:
            return .waningCrescent
        }
    }
}
