//
//  LocalStorage.swift
//  ULA Period Tracker
//
//  Created by eacalahorra.
//

import Foundation

protocol LocalStorage {
    func load<T: Codable>(_ type: T.Type, from file: String) -> T?
    func save<T: Codable>(_ value: T, to file: String)
}
