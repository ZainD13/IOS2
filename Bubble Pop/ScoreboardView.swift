import SwiftUI

struct ScoreboardView: View {
    
    @State private var scores: [ScoreEntry] = []

    var body: some View {
        VStack {

            Text("🏆 High Score Board")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(Array(sortedScores.enumerated()), id: \.element.id) { index, entry in
                    HStack {
                        Text("\(index + 1).")
                            .frame(width: 40, alignment: .leading)

                        Text(entry.name)

                        Spacer()

                        Text("\(entry.score)")
                            .bold()
                    }
                }
            }
        }
        .onAppear {
            scores = ScoreManager.loadScores()
        }
    }

    var sortedScores: [ScoreEntry] {
        scores.sorted { $0.score > $1.score }
    }
}
