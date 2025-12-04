//
//  PhaseEngine.swift
//  ULA Period Tracker
//  Created by eacalahorra.
//  Handles the logic for phase tracking, based on PredictionEngine...
//  Goes: Bleeding -> Fertile -> Ovulation -> Luteal -> Follicular -> Bleeding -> etc...
//  Update: bleeding is now captured via DayEntry exclusively... as otherwise, bleeding overtakes other phases. 

import Foundation

enum CyclePhase: String, Codable {
    case bleeding
    case follicular
    case fertileWindow
    case ovulation
    case luteal
    case unknown
}

struct PhaseEngine {
    
    private let calendar = Calendar.current
    
    func phase(
        for date: Date,
        lastPeriodStart: Date,
        predictedWindow: (min: Date, expected: Date, max: Date),
        ovulationDate: Date?,
        fertileWindow: (start: Date, end: Date)?
    ) -> CyclePhase {
        
        let startOfDay = calendar.startOfDay(for: date)
        // Fertile Window
        if let fertile = fertileWindow {
            if startOfDay >= calendar.startOfDay(for: fertile.start) &&
                startOfDay <= calendar.startOfDay(for: fertile.end) {
                return .fertileWindow
            }
        }
        // Ovulation
        if let ovu = ovulationDate {
            let ovulationDay = calendar.startOfDay(for: ovu)
            if startOfDay == ovulationDay {
                return .ovulation
            }
        }
        // Luteal Phase -- Calc'd based on Ovu, to pre next period.
        if let ovu = ovulationDate {
            if startOfDay > calendar.startOfDay(for: ovu) &&
                startOfDay < calendar.startOfDay(for: predictedWindow.expected) {
                return .luteal
            }
        }
        // Follicular phase for after bleeding, but before Fertile prediction. (Only when not bleeding)
        if startOfDay > calendar.startOfDay(for: lastPeriodStart) &&
            startOfDay < calendar.startOfDay(for: predictedWindow.min) {
            return .follicular
        }
        
        return .unknown
    }
    
    func phasesForMonth(
        dates: [Date],
        lastPeriodStart: Date,
        predictedWindow: (min: Date, expected: Date, max: Date),
        ovulationDate: Date?,
        fertileWindow: (start: Date, end: Date)?
    ) -> [Date: CyclePhase] {
        
        var result: [Date: CyclePhase] = [:]
        
        for date in dates {
            result[date] = phase(
                for: date,
                lastPeriodStart: lastPeriodStart,
                predictedWindow: predictedWindow,
                ovulationDate: ovulationDate,
                fertileWindow: fertileWindow
            )
        }
        
        return result
    }
}
