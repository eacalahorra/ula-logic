//
//  JSONStorage.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

struct JSONStorage: LocalStorage {
    
    private let fileManager = FileManager.default
    
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func load<T: Codable>(_ type: T.Type, from file: String) -> T? {
        let url = documentsURL.appendingPathComponent(file)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("JSON load error for \(file): \(error)")
            return nil
        }
    }
    
    func save<T: Codable>(_ value: T, to file: String) {
        let url = documentsURL.appendingPathComponent(file)
        
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("JSON save error for \(file): \(error)")
        }
    }
}
