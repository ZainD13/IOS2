import Foundation

struct ScoreEntry: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
}
