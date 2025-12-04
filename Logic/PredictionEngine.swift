//
//  PredictionEngine.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//
// for future reference. PAvC and BAvC are the Period Calculation logic. BAvC is simple and straight forward, the statistical average for period length based upon Mayo Clinic info... PAvC is an adaptive version of BAvC that "tries" to "predict" unregular cycles... it requires input from the user.

import Foundation

struct PredictionEngine {
    
    private let calendar = Calendar.current
    
    // Biological Average Calculation (BAvC) defaults
    private let defaultBAvCLength: Double = 28   // avg biological cycle length in days
    private let defaultLutealLength: Int = 14    // avg luteal phase length in days
    
    func computeBAvC() -> Double {
        return defaultBAvCLength
    }
    
    func computePAvC(from cycles: [Cycle], maxCount: Int = 6) -> Double? {
        let recent = Array(cycles.suffix(maxCount))
        guard recent.count >= 2 else { return nil } // Need minimum data otherwise no prediction.
        
        let lengths = recent.map { Double($0.length) }
        let sum = lengths.reduce(0, +)
        return sum / Double(lengths.count)
    }
    
    func computePAvCDeviation(from cycles: [Cycle], usingAverage avg: Double? = nil, maxCount: Int = 6) -> Double? {
        let recent = Array(cycles.suffix(maxCount))
        guard recent.count > 1 else { return nil } // Need at least 2 for std dev
        
        let avgValue = avg ?? (computePAvC(from: cycles, maxCount: maxCount) ?? defaultBAvCLength)
        let squaredDiffs = recent.map { pow(Double($0.length) - avgValue, 2.0) }
        let variance = squaredDiffs.reduce(0, +) / Double(recent.count - 1) // Sample std dev, if double rounded... we get askew asymmetric cycles...
        return sqrt(variance)
    }
    
    // MARK: -- Prediction Algos. -- god help me.
    
    func predictedPeriodWindow(lastPeriodStart: Date, cycles: [Cycle]) -> (min: Date, expected: Date, max: Date)? {
        let avg: Double
        if cycles.count >= 3, let pavc = computePAvC(from: cycles) {
            avg = pavc
        } else {
            avg = computeBAvC()
        }
        
        guard avg > 0 && avg < 60 else { return nil }
        let std: Double
        if cycles.count >= 4, let dev = computePAvCDeviation(from: cycles, usingAverage: avg) {
            std = dev
        } else {
            std = 3.0
        }
        let lowerBound = 2.0
        let upperBound = max(lowerBound, min(10.0, avg / 2))
        let clampedStd = max(lowerBound, min(std, upperBound))
        
        guard let expected = calendar.date(byAdding: .day, value: Int(round(avg)), to: lastPeriodStart),
              let minDate = calendar.date(byAdding: .day, value: Int(round(avg - clampedStd)), to: lastPeriodStart),
              let maxDate = calendar.date(byAdding: .day, value: Int(round(avg + clampedStd)), to: lastPeriodStart) else {
            return nil
        }
        
        return (min: minDate, expected: expected, max: maxDate)
    }
    
    func predictOvulation(expectedNextPeriodStart: Date) -> Date? {
        return calendar.date(byAdding: .day, value: -defaultLutealLength, to: expectedNextPeriodStart)
    }
    
    func fertileWindow(ovulationDate: Date) -> (start: Date, end: Date)? {
        guard let start = calendar.date(byAdding: .day, value: -5, to: ovulationDate),
              let end = calendar.date(byAdding: .day, value: 1, to: ovulationDate) else {
            return nil
        }
        return (start, end)
    }
}
