//
//  PhaseEngine.swift
//  ULA Period Tracker
//  Created by eacalahorra on 19/11/25.
//  Handles the logic for phase tracking, based on PredictionEngine...
//  Goes: Bleeding -> Fertile -> Ovulation -> Luteal -> Follicular -> Bleeding -> etc...
//  Update: bleeding is now captured via DayEntry exclusively... as otherwise, bleeding overtakes other phases. 

import Foundation

struct PhaseEngine {
    
    private let calendar = Calendar.current
    
    func phase(
        for date: Date,
        lastPeriodStart: Date,
        predictedWindow: (min: Date, expected: Date, max: Date),
        ovulationDate: Date?,
        fertileWindow: (start: Date, end: Date)?
    ) -> UlaCyclePhase {
        
        let startOfDay = calendar.startOfDay(for: date)

        if let ovu = ovulationDate {
            let ovulationDay = calendar.startOfDay(for: ovu)
            if startOfDay == ovulationDay {
                return .ovulation
            }
        }

        if let fertile = fertileWindow {
            if startOfDay >= calendar.startOfDay(for: fertile.start) &&
                startOfDay <= calendar.startOfDay(for: fertile.end) {
                return .peakFertility
            }
        }

        let predictedMin = calendar.startOfDay(for: predictedWindow.min)
        let predictedMax = calendar.startOfDay(for: predictedWindow.max)

        if startOfDay >= predictedMin && startOfDay <= predictedMax {
            return .lutealPrePeriod
        }

        if let fertile = fertileWindow {
            let fertileEnd = calendar.startOfDay(for: fertile.end)
            if startOfDay > fertileEnd && startOfDay < predictedMin {
                return .luteal
            }
        }

        if startOfDay > calendar.startOfDay(for: lastPeriodStart) {
            return .follicular
        }
        
        return .follicular
    }
    
    func phasesForMonth(
        dates: [Date],
        lastPeriodStart: Date,
        predictedWindow: (min: Date, expected: Date, max: Date),
        ovulationDate: Date?,
        fertileWindow: (start: Date, end: Date)?
    ) -> [Date: UlaCyclePhase] {
        
        var result: [Date: UlaCyclePhase] = [:]
        
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
