//
//  ScoreManager.swift
//  Bubble Pop
//
//  Created by Damaq Mohd Zain on 25/4/2026.
//


import Foundation

class ScoreManager {
    
    static let key = "scoreboard"

    static func loadScores() -> [ScoreEntry] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            return decoded
        }
        return []
    }

    static func saveScores(_ scores: [ScoreEntry]) {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    static func addScore(name: String, score: Int) {
        var scores = loadScores()
        scores.append(ScoreEntry(name: name, score: score))
        scores.sort { $0.score > $1.score }
        scores = Array(scores.prefix(10))
        saveScores(scores)
    }
}