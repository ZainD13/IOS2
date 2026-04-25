import SwiftUI

struct PlayView: View {
    
    @Binding var path: NavigationPath
    let name: String
    
    @AppStorage("duration") private var duration: Double = 45
    
    @State private var timer: Timer? = nil
    @State private var timeRemaining: Int = 45
    @State private var timerRunning = false
    
    @State private var score: Int = 0
    @AppStorage("highScore") private var highScore: Int = 0
    
    @AppStorage("numberOfBubbles") private var numberOfBubbles: Double = 10

    struct Bubble: Identifiable, Equatable {
        let id = UUID()
        var position: CGPoint
        var color: Color
        var size: CGFloat
    }

    @State private var bubbles: [Bubble] = []
    @State private var containerSize: CGSize = .zero
    @State private var appearing: Set<UUID> = []

    private let bubbleSize: CGFloat = 70
    private let bubbleColor: Color = .blue

    var body: some View {
        VStack {

            HStack {
                Text("Time: \(timeRemaining)")
                Spacer()
                Text("Score: \(score)")
                Spacer()
                Text("High: \(highScore)")
            }
            .padding()

            Spacer()

            ZStack {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            containerSize = geo.size
                            seedBubbles()
                        }
                        .onChange(of: geo.size) { _, newValue in
                            containerSize = newValue
                            seedBubbles()
                        }
                        .contentShape(Rectangle())
                }
                .ignoresSafeArea(edges: .bottom)

                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(bubbleColor)
                        .frame(width: bubbleSize, height: bubbleSize)
                        .position(bubble.position)
                        .opacity(appearing.contains(bubble.id) ? 1 : 0)
                        .onAppear {
                            if !appearing.contains(bubble.id) {
                                appearing.insert(bubble.id)
                            }
                        }
                        .animation(.easeIn(duration: 0.25), value: appearing)
                        .onTapGesture {
                            pop(bubble)
                        }
                        .shadow(radius: 4)
                }
            }
        }
        .onAppear {
            timer?.invalidate()
            timer = nil

            score = 0
            timeRemaining = Int(duration)
            timerRunning = false
            bubbles.removeAll()
            appearing.removeAll()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                seedBubbles()
                startTimer()
            }
        }
        .onChange(of: numberOfBubbles) { _, _ in
            seedBubbles()
        }
        
        .onDisappear {
            timer?.invalidate()
            timer = nil
            timerRunning = false
        }
    }

    // MARK: - Timer

    func startTimer() {

        timer?.invalidate()
        timer = nil

        timerRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                t.invalidate()
                timer = nil
                timerRunning = false

                ScoreManager.addScore(name: name, score: score)
                path.append(score)
            }
        }
    }

    // MARK: - Bubble logic

    func seedBubbles() {
        guard containerSize.width > 0, containerSize.height > 0 else { return }

        let target = Int(numberOfBubbles)

        if bubbles.count >= target { return }

        var attempts = 0

        while bubbles.count < target && attempts < 500 {
            let bubble = randomBubble()
            bubbles.append(bubble)
            attempts += 1
        }
    }

    func maybeSpawnBubble() {
        let target = Int(numberOfBubbles)
        guard bubbles.count < target else { return }
        bubbles.append(randomBubble())
    }

    func randomBubble() -> Bubble {

        let inset = bubbleSize / 2

        let x = CGFloat.random(in: inset...(max(inset, containerSize.width - inset)))
        let y = CGFloat.random(in: inset...(max(inset, containerSize.height - inset)))

        return Bubble(
            position: CGPoint(x: x, y: y),
            color: bubbleColor,
            size: bubbleSize
        )
    }

    // MARK: - Pop

    func pop(_ bubble: Bubble) {
        if let idx = bubbles.firstIndex(of: bubble) {
            bubbles.remove(at: idx)

            score += 5
            if score > highScore { highScore = score }

            if timerRunning {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...2)) {
                    if timerRunning {
                        maybeSpawnBubble()
                    }
                }
            }
        }
    }
}

#Preview {
    PlayView(
        path: .constant(NavigationPath()),
        name: "Test Player"
    )
}
