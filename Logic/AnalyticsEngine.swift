//
//  AnalyticsEngine.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

// MARK: - Analytics Data Types

struct CycleStats {
    let count: Int
    let averageLength: Double?
    let medianLength: Double?
    let minLength: Int?
    let maxLength: Int?
    let standardDeviation: Double?
}

struct PeriodStats {
    let count: Int
    let averageLength: Double?
    let medianLength: Double?
    let minLength: Int?
    let maxLength: Int?
    let standardDeviation: Double?
}

struct IrregularStats {
    let total: Int
    let tooShortCount: Int
    let tooLongCount: Int
    let recentIrregularCount: Int
}

struct PredictionConfidence {
    // 0.0 to 1.0
    let value: Double
}

// MARK: - Analytics Engine

struct AnalyticsEngine {
    private let calendar = Calendar.current
    
    // MARK: Cycle Stats
    
    func cycleStats(from cycles: [Cycle]) -> CycleStats {
        let lengths = cycles.map { cycleLength($0) }.sorted()
        return makeStats(from: lengths)
    }
    
    // MARK: Period Stats
    
    func periodStats(from periods: [PeriodEpisode]) -> PeriodStats {
        let lengths = periods.map { periodLength($0) }.sorted()
        let base = makeStats(from: lengths)
        return PeriodStats(
            count: base.count,
            averageLength: base.averageLength,
            medianLength: base.medianLength,
            minLength: base.minLength,
            maxLength: base.maxLength,
            standardDeviation: base.standardDeviation
        )
    }
    
    // MARK: Irregular Stats
    
    func irregularStats(from irregular: [IrregularCycle], recentDays: Int = 180) -> IrregularStats {
        let tooShort = irregular.filter { $0.reason == .tooShort }.count
        let tooLong = irregular.filter { $0.reason == .tooLong }.count
        
        let cutoff = calendar.date(byAdding: .day, value: -recentDays, to: Date()) ?? Date.distantPast
        let recent = irregular.filter { $0.toStart >= cutoff }.count
        
        return IrregularStats(
            total: irregular.count,
            tooShortCount: tooShort,
            tooLongCount: tooLong,
            recentIrregularCount: recent
        )
    }
    
    // MARK: Prediction Confidence
    
    func predictionConfidence(from cycles: [Cycle]) -> PredictionConfidence {
        let lengths = cycles.map { cycleLength($0) }
        guard lengths.count >= 2 else {
            // Too little data
            return PredictionConfidence(value: 0.2)
        }
        
        let mean = average(of: lengths)
        let std = standardDeviation(of: lengths, mean: mean)
        if mean == 0 {
            return PredictionConfidence(value: 0.0)
        }
        
        // ratio of variation vs mean
        let variability = std / Double(mean)
        
        // It's heuristic. The more variability, the lower confidence.
        let raw = 1.0 - min(variability / 0.3, 1.0)
        return PredictionConfidence(value: max(0.0, min(1.0, raw)))
    }
    
    // MARK: - Helpers
    
    private func cycleLength(_ cycle: Cycle) -> Int {
        let comps = calendar.dateComponents([.day], from: cycle.startDate, to: cycle.endDate)
        return comps.day ?? 0
    }
    
    private func periodLength(_ episode: PeriodEpisode) -> Int {
        let comps = calendar.dateComponents([.day], from: episode.startDate, to: episode.endDate)
        // include both start and end days as full bleeding days
        return (comps.day ?? 0) + 1
    }
    
    private func average(of values: [Int]) -> Double {
        guard !values.isEmpty else { return 0.0 }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
    
    private func standardDeviation(of values: [Int], mean: Double? = nil) -> Double {
        guard values.count >= 2 else { return 0.0 }
        let m = mean ?? average(of: values)
        let variance = values
            .map { pow(Double($0) - m, 2.0) }
            .reduce(0.0, +) / Double(values.count - 1)
        return sqrt(variance)
    }
    
    private func median(of values: [Int]) -> Double? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        
        if sorted.count % 2 == 0 {
            return (Double(sorted[mid - 1]) + Double(sorted[mid])) / 2.0
        } else {
            return Double(sorted[mid])
        }
    }
    
    private func makeStats(from lengths: [Int]) -> CycleStats {
        guard !lengths.isEmpty else {
            return CycleStats(
                count: 0,
                averageLength: nil,
                medianLength: nil,
                minLength: nil,
                maxLength: nil,
                standardDeviation: nil
            )
        }
        
        let avg = average(of: lengths)
        let med = median(of: lengths)
        let minVal = lengths.min()
        let maxVal = lengths.max()
        let std = standardDeviation(of: lengths, mean: avg)
        
        return CycleStats(
            count: lengths.count,
            averageLength: avg,
            medianLength: med,
            minLength: minVal,
            maxLength: maxVal,
            standardDeviation: std
        )
    }
}
