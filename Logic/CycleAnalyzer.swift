//
//  CycleAnalyzer.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

struct CycleAnalyzer {
    private let minCycleLength = 12
    private let maxCycleLength = 90
    
    func buildCycles(from episodes: [PeriodEpisode]) -> (cycles: [Cycle], irregular: [IrregularCycle]) {
        let sorted = episodes.sorted(by: { $0.startDate < $1.startDate })
        
        guard sorted.count >= 2 else {
            return (cycles: [], irregular: [])
        }
        
        var cycles: [Cycle] = []
        var irregular: [IrregularCycle] = []
        let calendar = Calendar.current
        
        for i in 0..<(sorted.count - 1) {
            let current = sorted [i]
            let next = sorted [i + 1]
            
            let length = calendar.dateComponents([.day], from: current.startDate, to: next.startDate).day ?? 0
            
            if length < minCycleLength {
                let ir = IrregularCycle(
                    id: UUID(),
                    fromStart: current.startDate,
                    toStart: next.startDate,
                    length: length,
                    reason: .tooShort
                )
                irregular.append(ir)
                continue
            }
            
            if length > maxCycleLength {
                let ir = IrregularCycle(
                    id: UUID(),
                    fromStart: current.startDate,
                    toStart: next.startDate,
                    length: length,
                    reason: .tooLong
                )
                irregular.append(ir)
                continue
            }
            
            let cycle = Cycle(
                id: UUID(),
                startDate: current.startDate,
                endDate: next.startDate
            )
            
            cycles.append(cycle)
        }
        return (cycles: cycles, irregular: irregular)
    }
}

struct IrregularCycle: Identifiable, Codable {
    let id: UUID
    let fromStart: Date
    let toStart: Date
    let length: Int
    let reason: IrregularReason
}

enum IrregularReason: String, Codable {
    case tooShort
    case tooLong
}

