//
//  ScoreboardView.swift
//  Bubble Pop
//
//  Created by Damaq Mohd Zain on 25/4/2026.
//


import SwiftUI

struct ScoreboardView: View {
    
    @State private var scores: [ScoreEntry] = []

    var body: some View {
        VStack {
            Text("Scoreboard")
                .font(.largeTitle)
                .padding()

            List(scores) { entry in
                HStack {
                    Text(entry.name)
                    Spacer()
                    Text("\(entry.score)")
                }
            }

            Button("Clear Scores") {
                ScoreManager.saveScores([])
                scores = []
            }
            .padding()
        }
        .onAppear {
            scores = ScoreManager.loadScores()
        }
    }
}