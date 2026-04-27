import SwiftUI

enum Route: Hashable {
    case name
    case settings
    case play(String)
    case scoreboard
    case score(Int)
}

struct ContentView: View {

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {

            VStack {
                Text("Bubble Pop")
                    .padding(50)
                    .font(.largeTitle)
                    .bold()

                Button("Play") {
                    path.append(Route.name)
                }
                .padding(10)

                Button("Settings") {
                    path.append(Route.settings)
                }
                .padding(10)

                Button("Scoreboard") {
                    path.append(Route.scoreboard)
                }
                .padding(10)
            }

            .navigationDestination(for: Route.self) { route in
                switch route {

                case .name:
                    NameEntryView(path: $path)

                case .settings:
                    SettingsView()

                case .play(let name):
                    PlayView(path: $path, name: name)

                case .scoreboard:
                    ScoreboardView()

                case .score(let finalScore):
                    ScoreView(
                        path: $path,
                        finalScore: finalScore,
                        highScore: UserDefaults.standard.integer(forKey: "highScore")
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
