//
//  PeriodDetector.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

struct PeriodDetector {
    
    func detectPeriods(from entries: [DayEntry]) -> [PeriodEpisode] {
        let sorted = entries.sorted(by: { $0.date < $1.date })
        var episodes: [PeriodEpisode] = []
        
        var currentStart: Date? = nil
        var currentDays: [DayEntry] = []
        var pendingZeroCount = 0
        
        var loggedBleedingDates: [Date] = []
        var lastBleedingDate: Date? = nil
        var firstZeroDate: Date? = nil
        var secondZeroDate: Date? = nil
        
        for entry in sorted {
            if entry.isPeriodStart {
                if let start = currentStart {
                    let episode = finalizeEpisode(start: start, days: currentDays)
                    episodes.append(episode)
                }
                
                currentStart = entry.date
                currentDays = [entry]
                pendingZeroCount = 0
                continue
            }
            // MARK: if period is active -- If something breaks with period functions is this, especially regarding ending a period.
            if let _ = currentStart {
                if entry.bleeding > 0 {
                    loggedBleedingDates.append(entry.date)
                    lastBleedingDate = entry.date
                }
                if entry.bleeding > 0 {
                    // continue as long as bleeding is >1
                    currentDays.append(entry)
                    pendingZeroCount = 0
                } else if entry.bleeding == 0 {
                    // WHEN bleeding = 0, possible end, check the next day. If bleeding = 0 next day... done.
                    pendingZeroCount += 1
                    if pendingZeroCount == 1 {
                        firstZeroDate = entry.date
                        continue
                    }
                    if pendingZeroCount >= 2 {
                        secondZeroDate = entry.date
                        if let start = currentStart {
                            let episode = finalizeEpisode(start: start, days: currentDays)
                            episodes.append(episode)
                        }
                        currentStart = nil
                        currentDays = []
                        pendingZeroCount = 0
                        firstZeroDate = nil
                        secondZeroDate = nil
                    }
                }
                continue
            }
        }
        
        if let start = currentStart {
            let cal = Calendar.current

            // RULE ABOSLUTE: zero2 rule -- Overrules ALL other rules
            if let zero2 = secondZeroDate {
                let episode = PeriodEpisode(
                    id: UUID(),
                    startDate: start,
                    endDate: zero2,
                    days: currentDays
                )
                episodes.append(episode)
                return episodes
            }

            let loggedCount = loggedBleedingDates.count
            let lastLogged = lastBleedingDate ?? start

            let avgPeriod = 7
            let majorityThreshold = 4
            let maxPeriod = 10
            let graceAfterLastLog = 4

            var autoEnd: Date?

            // If user logs less than the majority of days, shut off after 7 days.
            if loggedCount < majorityThreshold {
                autoEnd = cal.date(byAdding: .day, value: avgPeriod - 1, to: start)
            }
            else {
                autoEnd = cal.date(byAdding: .day, value: graceAfterLastLog, to: lastLogged)
            }

            let maxEnd = cal.date(byAdding: .day, value: maxPeriod - 1, to: start)!

            let chosenEnd = min(autoEnd ?? maxEnd, maxEnd)

            let episode = PeriodEpisode(
                id: UUID(),
                startDate: start,
                endDate: chosenEnd,
                days: currentDays
            )
            episodes.append(episode)
            firstZeroDate = nil
        }

        return episodes
    }
    
    private func finalizeEpisode(start: Date, days: [DayEntry]) -> PeriodEpisode {
        let endDate = days.last?.date ?? start
        return PeriodEpisode(
            id: UUID(),
            startDate: start,
            endDate: endDate,
            days: days
        )
    }
}
