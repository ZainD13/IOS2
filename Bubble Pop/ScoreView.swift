import SwiftUI

struct ScoreView: View {
    @Binding var path: NavigationPath
    let finalScore: Int
    let highScore: Int

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)

            Text("Your Score: \(finalScore)")
                .font(.title)

            Text("High Score: \(highScore)")
                .font(.title2)

            // Go back to home screen
            Button("Main Menu") {
                path = NavigationPath()
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true) // disable back button
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    ScoreView(path: $path, finalScore: 11, highScore: 23)
}
