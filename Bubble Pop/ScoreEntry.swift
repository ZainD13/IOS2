//
//  ScoreEntry.swift
//  Bubble Pop
//
//  Created by Damaq Mohd Zain on 25/4/2026.
//


import Foundation

struct ScoreEntry: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
}
