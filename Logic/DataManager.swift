//
//  DataManager.swift
//  ULA Period Tracker
//
//  Created by eacalahorra on 19/11/25.
//  It should work(?) I tried my best.

import Foundation
import Combine
import SwiftUI

#Preview {
    ContentView()
}

@MainActor
class DataManager: ObservableObject {
    
    // MARK: - @Published Outputs... -- UI follows these.
    @Published var entries: [DayEntry] = []
    @Published var periods: [PeriodEpisode] = []
    @Published var cycles: [Cycle] = []
    @Published var irregularCycles: [IrregularCycle] = []
    @Published var forecasts: [CycleForecast] = []
    @Published var predictions: (min: Date, expected: Date, max: Date)?
    @Published var ovulationDate: Date?
    @Published var fertileWindow: (start: Date, end: Date)?
    @Published var phasesForCalendar: [Date: UlaCyclePhase] = [:]
    @Published var moonPhasesForCalendar: [Date: MoonPhase] = [:]
    @Published var sexEvents: [SexEvent] = []
    @Published var symptoms: [Symptom] = []
    @Published var externalSDISRequest: SDISRequest? = nil
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isRegularUser: Bool = true
    @Published var onboardingLastPeriodStart: Date? = nil

    // MARK: - Day Summary Struct for UI Popover
    struct DaySummary {
        let date: Date
        let bleeding: Int?
        let isPeriodStart: Bool
        let sexEvents: [SexEvent]
        let symptoms: [SymptomType]

        var hasAnyData: Bool {
            return bleeding != nil || !sexEvents.isEmpty || !symptoms.isEmpty
        }
    }

    // MARK: - Logic Engines
    private let detector = PeriodDetector()
    private let analyzer = CycleAnalyzer()
    private let predictionEngine = PredictionEngine()
    private let storage: any LocalStorage
    private let legacyEntriesFile = "DayEntry.json" // Legacy Storage, see Schema.
    private let moonEngine = MoonPhaseEngine()
    private let legacySexEventsFile = "SexEvents.json" // Legacy Storage, see Schema.
    private let schemaFile = "ULAData.json"
    private let currentSchemaVersion = 1
    private let symptomsEngine = SymptomsEngine()
    
    // MARK: - Init
    init() {
        self.storage = JSONStorage()

        loadSchema()
        refreshAllLogic()
    }

    init(storage: any LocalStorage, shouldLoadPersistedState: Bool = true) {
        self.storage = storage

        if shouldLoadPersistedState {
            loadSchema()
        }

        refreshAllLogic()
    }
    
    // MARK: - Core Logic Execution
    
    func refreshAllLogic() {
        // Detect Period
        periods = detector.detectPeriods(from: entries)
        
        // Build cycles + Irregular Cycles Now Considered...
        let cycleResult = analyzer.buildCycles(from: periods)
        cycles = cycleResult.cycles
        irregularCycles = cycleResult.irregular
        
        guard let lastPeriod = predictionAnchorDate() else {
            forecasts = []
            predictions = nil
            ovulationDate = nil
            fertileWindow = nil
            phasesForCalendar = [:]
            moonPhasesForCalendar = [:]
            return
        }

        let usePersonalizedPrediction = predictionEngine.shouldUsePersonalizedPrediction(
            cycles: cycles,
            isRegularUser: isRegularUser
        )

        forecasts = predictionEngine.forecastCycles(
            lastPeriodStart: lastPeriod,
            cycles: cycles,
            count: 6,
            usePersonalizedPrediction: usePersonalizedPrediction
        )

        if let firstForecast = forecasts.first {
            predictions = firstForecast.periodWindow
            ovulationDate = firstForecast.ovulationDate
            fertileWindow = firstForecast.fertileWindow
        } else {
            predictions = nil
            ovulationDate = nil
            fertileWindow = nil
        }

        phasesForCalendar = computePhasesForForecastRange()
    }

    private func predictionAnchorDate() -> Date? {
        if let lastPeriodStart = periods.last?.startDate {
            return lastPeriodStart
        }

        return onboardingLastPeriodStart
    }
    
    // MARK: - Phase Computation for forecast range.
    
    private func computePhasesForForecastRange() -> [Date: UlaCyclePhase] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let horizonMonth = calendar.date(byAdding: .month, value: 5, to: monthStart),
              let monthRange = calendar.range(of: .day, in: .month, for: horizonMonth),
              let rangeEnd = calendar.date(byAdding: .day, value: monthRange.count - 1, to: horizonMonth)
        else {
            return [:]
        }

        var phases: [Date: UlaCyclePhase] = [:]
        var moonPhases: [Date: MoonPhase] = [:]

        var current = monthStart
        while current <= rangeEnd {
            let startOfDay = calendar.startOfDay(for: current)
            // Moon Phases
            moonPhases[startOfDay] = moonEngine.phase(for: startOfDay)
            phases[startOfDay] = phase(on: startOfDay)

            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }

        moonPhasesForCalendar = moonPhases
        return phases
    }
    
    // MARK: JSON Storage.
    func loadEntries() {
        loadSchema()
    }
    
    func saveEntries() {
        saveSchema()
    }
    
    func loadSexEvents() {
       loadSchema()
    }
    
    func saveSexEvents() {
        saveSchema()
    }
    
    private func legacyLoadEntries() -> [DayEntry] {
        storage.load([DayEntry].self, from: legacyEntriesFile) ?? []
    }
    
    private func legacyLoadSexEvents() -> [SexEvent] {
        storage.load([SexEvent].self, from: legacySexEventsFile) ?? []
    }
    
    // MARK: - Remember Entry Action
    
    func addOrUpdateEntry(_ entry: DayEntry) {
        if let index = entries.firstIndex(where: {Calendar.current.isDate($0.date, inSameDayAs: entry.date)}) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        entries.sort { $0.date < $1.date }
        saveSchema()
        refreshAllLogic()
    }

    func logBleeding(on date: Date, level: Int) {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)
        let clamped = max(0, min(4, level))
        
        if let index = entries.firstIndex(where: { cal.isDate($0.date, inSameDayAs: normalized) }) {
            entries[index].bleeding = clamped
        } else {
            let newEntry = DayEntry(
                date: normalized,
                bleeding: clamped,
                isPeriodStart: false
            )
            entries.append(newEntry)
        }
        
        entries.sort { $0.date < $1.date }
        saveSchema()
        refreshAllLogic()
        debugPrintState(label: "logBleeding on \(normalized)")
    }
    
    func startPeriod(on date: Date = Date(), bleedingLevel: Int = 1) {
        // If user starts a period, this is a manual override of any prediction.
        // Validation: refuse future dates.
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let normalized = cal.startOfDay(for: date)
        
        guard normalized <= today else {
            print("Refusing to start period in the future.")
            return
        }
        
        let level = max(1, min(4, bleedingLevel))
        
        // Check if data exists for date.
        if let index = entries.firstIndex(where: { cal.isDate($0.date, inSameDayAs: normalized) }) {
            // Mark explicit period start on that day.
            entries[index].isPeriodStart = true
            entries[index].bleeding = level
        } else {
            // Create a new entry explicitly marking start
            let newEntry = DayEntry(
                date: normalized,
                bleeding: level,
                isPeriodStart: true
            )
            entries.append(newEntry)
        }
        
        entries.sort { $0.date < $1.date }
        saveSchema()
        refreshAllLogic()
        debugPrintState(label: "startPeriod on \(normalized)")
    }
    
    func undoPeriodStart(on date: Date) {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)
        
        if let index = entries.firstIndex(where: { cal.isDate($0.date, inSameDayAs: normalized) && $0.isPeriodStart }) {
            entries[index].isPeriodStart = false
        }
        
        entries.sort { $0.date < $1.date }
        saveSchema()
        refreshAllLogic()
        debugPrintState(label: "undoPeriodStart on \(normalized)")
    }
    
    func addSexEvent(on date: Date, protected: Bool) {
        let event = SexEvent(id: UUID(), date: date, protected: protected)
        sexEvents.append(event)
        sexEvents.sort { $0.date < $1.date }
        saveSchema()
        debugPrintState(label: "addSexEvent on \(date)")
    }
    // Groups multiple sexEvents in 1 date to show in Calendar View -- Takes into consideration people can have >1 sexEvent/day
    func sexEventsByDay() -> [Date: [SexEvent]] {
        var dict: [Date: [SexEvent]] = [:]
        let cal = Calendar.current
        
        for event in sexEvents {
            let day = cal.startOfDay(for: event.date)
            dict[day, default: []].append(event)
        }
        
        return dict
    }
    
    func logSymptoms(on date: Date, symptoms symptomTypes: Set<SymptomType>) {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)
        
        // Remove existing symptoms for that day
        symptoms.removeAll { cal.isDate($0.date, inSameDayAs: normalized) }
        
        // Add new set
        let newSymptoms: [Symptom] = symptomTypes.map { type in
            Symptom(
                id: UUID(),
                date: normalized,
                type: type,
                intensity: nil,
                note: nil
            )
        }
        
        symptoms.append(contentsOf: newSymptoms)
        // Optionally sort if needed
        symptoms.sort { $0.date < $1.date }
        
        // Persist via schema
        saveSchema()
        debugPrintState(label: "logSymptoms on \(normalized)")
    }
    
    //MARK: Schema Versioning.
    func saveSchema() {
        let wrapper = ULASchemaWrapper(
            schemaVersion: currentSchemaVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0",
            entries: entries,
            sexEvents: sexEvents,
            symptoms: symptoms,
            hasCompletedOnboarding: hasCompletedOnboarding,
            isRegularUser: isRegularUser,
            onboardingLastPeriodStart: onboardingLastPeriodStart
            
        )
        storage.save(wrapper, to: schemaFile)
    }
    
    func loadSchema() {
        if let wrapper: ULASchemaWrapper = storage.load(ULASchemaWrapper.self, from: schemaFile) {
            
            self.entries = wrapper.entries
            self.sexEvents = wrapper.sexEvents
            self.symptoms = wrapper.symptoms ?? []
            self.hasCompletedOnboarding = wrapper.hasCompletedOnboarding
            self.isRegularUser = wrapper.isRegularUser
            self.onboardingLastPeriodStart = wrapper.onboardingLastPeriodStart
            
            if wrapper.schemaVersion < currentSchemaVersion {
                migrateSchema(from: wrapper)
            }
        } else {
            print ("No schema found. ATTEMPTING LEGACY LOAD.")
            
            self.entries = legacyLoadEntries()
            self.sexEvents = legacyLoadSexEvents()
            
            self.symptoms = []
            
            saveSchema()
        }
    }
    
    func migrateSchema(from old: ULASchemaWrapper) {
        print("Migrating Schema from v\(old.schemaVersion) to v\(currentSchemaVersion)")
        saveSchema()
    }
    
    func isPeriodActive(on date: Date) -> Bool {
        let cal = Calendar.current
        let target = cal.startOfDay(for: date)
        
        for episode in periods {
            if episode.startDate <= target && target <= episode.endDate {
                return true
            }
        }
        return false
    }
    
    var isPeriodActive: Bool {
        return isPeriodActive(on: Date())
    }

    func currentPeriodStartDate(on date: Date) -> Date? {
        let cal = Calendar.current
        let target = cal.startOfDay(for: date)

        for episode in periods {
            if episode.startDate <= target && target <= episode.endDate {
                return episode.startDate
            }
        }

        return nil
    }

    // MARK: - Day Summary Builder
    func summary(for date: Date) -> DaySummary {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)

        // Bleeding
        let bleedingEntry = entries.first(where: { cal.isDate($0.date, inSameDayAs: normalized) })
        let bleeding = bleedingEntry?.bleeding
        let startFlag = bleedingEntry?.isPeriodStart ?? false

        // Sex Events
        let dailySex = sexEvents.filter { cal.isDate($0.date, inSameDayAs: normalized) }

        // Symptoms
        let dailySymptoms = symptoms
            .filter { cal.isDate($0.date, inSameDayAs: normalized) }
            .map { $0.type }

        return DaySummary(
            date: normalized,
            bleeding: bleeding,
            isPeriodStart: startFlag,
            sexEvents: dailySex,
            symptoms: dailySymptoms
        )
    }

    // MARK: - Phase Resolution for UI Theme
    func phase(on date: Date) -> UlaCyclePhase {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)

        if isPeriodActive(on: day) {
            return .period
        }

        for forecast in forecasts {
            let periodWindow = forecast.periodWindow
            let minD = cal.startOfDay(for: periodWindow.min)
            let maxD = cal.startOfDay(for: periodWindow.max)
            let ovulationDay = cal.startOfDay(for: forecast.ovulationDate)
            let fertileStart = cal.startOfDay(for: forecast.fertileWindow.start)
            let fertileEnd = cal.startOfDay(for: forecast.fertileWindow.end)

            if cal.isDate(day, inSameDayAs: ovulationDay) {
                return .ovulation
            }

            if day >= fertileStart && day <= fertileEnd {
                return .peakFertility
            }

            if day >= minD && day <= maxD {
                return .lutealPrePeriod
            }

            if day > fertileEnd && day < minD {
                return .luteal
            }
        }

        return .follicular
    }

    // MARK: - Update Functions for Editing Existing Data

    // Update all logged sex events for a day to match the day-level edit UI.
    func updateSexEvents(on date: Date, protected: Bool) {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)

        let indexes = sexEvents.indices.filter { cal.isDate(sexEvents[$0].date, inSameDayAs: normalized) }
        guard !indexes.isEmpty else { return }

        for index in indexes {
            sexEvents[index].protected = protected
        }

        saveSchema()
    }

    // Update bleeding level for a given day (edit mode).
    func updateBleeding(on date: Date, to level: Int) {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)
        let clamped = max(0, min(4, level))

        if let index = entries.firstIndex(where: { cal.isDate($0.date, inSameDayAs: normalized) }) {
            entries[index].bleeding = clamped
            saveSchema()
            refreshAllLogic()
            debugPrintState(label: "updateBleeding")
        }
    }

    // Update symptoms for a given day (edit mode).
    func updateSymptoms(on date: Date, to newSet: Set<SymptomType>) {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)

        // Remove existing symptoms for that day
        symptoms.removeAll { cal.isDate($0.date, inSameDayAs: normalized) }

        // Add the updated set
        let updatedSymptoms = newSet.map {
            Symptom(id: UUID(), date: normalized, type: $0, intensity: nil, note: nil)
        }

        symptoms.append(contentsOf: updatedSymptoms)
        saveSchema()
        debugPrintState(label: "updateSymptoms")
    }

    // MARK: Onboarding Functions.
    func applyOnboardingData(isRegular: Bool, lastPeriodStart: Date?) {
        self.isRegularUser = isRegular
        self.onboardingLastPeriodStart = lastPeriodStart

        self.hasCompletedOnboarding = true
        saveSchema()
        refreshAllLogic()
    }

    func nextUpcomingPeriodForecast(from date: Date = Date()) -> CycleForecast? {
        let target = Calendar.current.startOfDay(for: date)

        return forecasts.first { forecast in
            Calendar.current.startOfDay(for: forecast.periodWindow.expected) >= target
        }
    }

    func nextUpcomingOvulationForecast(from date: Date = Date()) -> CycleForecast? {
        let target = Calendar.current.startOfDay(for: date)

        return forecasts.first { forecast in
            Calendar.current.startOfDay(for: forecast.ovulationDate) >= target
        }
    }
    
    // MARK: DELETE ALL DATA
    
    func deleteAllData() {
        entries.removeAll()
        periods.removeAll()
        cycles.removeAll()
        irregularCycles.removeAll()
        forecasts.removeAll()
        sexEvents.removeAll()
        symptoms.removeAll()
        
        predictions = nil
        ovulationDate = nil
        fertileWindow = nil
        phasesForCalendar = [:]
        moonPhasesForCalendar = [:]
        hasCompletedOnboarding = false
        isRegularUser = true
        onboardingLastPeriodStart = nil
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
        
        saveSchema()
        
        refreshAllLogic()
    }
    
    // MARK: - Debug Inspector
    func debugPrintState(label: String = "") {
        #if DEBUG
        let tag = label.isEmpty ? "" : " – \(label)"
        print("\n=== ULA LOGIC LIVE STATE\(tag) ===")
        print("Entries: \(entries.count)")
        print("Periods: \(periods.count)")
        print("Cycles: \(cycles.count)")
        print("Sex events: \(sexEvents.count)")
        print("Symptoms: \(symptoms.count)")

        if let predictions = predictions {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            print("Prediction window:")
            print("  Min:      \(formatter.string(from: predictions.min))")
            print("  Expected: \(formatter.string(from: predictions.expected))")
            print("  Max:      \(formatter.string(from: predictions.max))")
        } else {
            print("Prediction window: none")
        }

        let today = Date()
        let todaySummary = summary(for: today)
        print("Today summary:")
        print("  bleeding=\(todaySummary.bleeding ?? -1)")
        print("  isPeriodStart=\(todaySummary.isPeriodStart)")
        print("  sexEvents=\(todaySummary.sexEvents.count)")
        print("  symptoms=\(todaySummary.symptoms.count)")
        print("  isPeriodActive(today)=\(isPeriodActive(on: today))")
        print("==============================================\n")
        #endif
    }
}
