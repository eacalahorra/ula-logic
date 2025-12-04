//
//  SymptomsEngine.swift
//  Ula
//
//  Created by eacalahorra.
//

import Foundation

struct SymptomsEngine {
    
    func symptomsByDay(_ symtpoms: [Symptom]) -> [Date: [Symptom]] {
        var dict: [Date: [Symptom]] = [:]
        let cal = Calendar.current
        
        for symptom in symtpoms {
            let day = cal.startOfDay(for: symptom.date)
            dict[day, default: []].append(symptom)
        }
        
        return dict
    }
    
    func symptoms(on date: Date, from symptoms: [Symptom]) -> [Symptom] {
        let cal = Calendar.current
        return symptoms.filter { cal.isDate($0.date, inSameDayAs: date)}
    }
}
