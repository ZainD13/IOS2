import SwiftUI

struct NameEntryView: View {

    @Binding var path: NavigationPath
    @State private var playerName: String = ""

    var body: some View {
        VStack(spacing: 20) {

            Text("Enter your name")
                .font(.title)

            TextField("Name", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Start Game") {
                startGame()
            }
            .disabled(playerName.isEmpty)
        }
        .padding()
    }

    func startGame() {
        // Navigate to PlayView WITH the name
        path.append(Route.play(playerName))
    }
}
