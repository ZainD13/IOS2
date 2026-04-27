import SwiftUI

struct PlayView: View {
    
    @Binding var path: NavigationPath
    let name: String
    
    @AppStorage("duration") private var duration: Double = 60
    @AppStorage("numberOfBubbles") private var numberOfBubbles: Double = 15
    
    @State private var timer: Timer? = nil
    @State private var timeRemaining: Int = 60
    @State private var timerRunning = false
    
    @State private var score: Int = 0
    @AppStorage("highScore") private var highScore: Int = 0

    struct Bubble: Identifiable, Equatable {
        let id = UUID()
        var position: CGPoint
        var color: Color
        var size: CGFloat
        var points: Int
    }

    @State private var bubbles: [Bubble] = []
    @State private var containerSize: CGSize = .zero
    @State private var appearing: Set<UUID> = []

    @State private var lastBubbleColor: Color? = nil
    @State private var comboCount: Int = 0
    @State private var preGameCount: Int = 3
    @State private var showingCountdown: Bool = true

    private let bubbleSize: CGFloat = 70
    private let maxAllowedBubbles = 100

    let bubbleTypes: [(color: Color, points: Int, probability: Double)] = [
        (.red, 1, 0.40),
        (Color(red: 1.0, green: 0.2, blue: 0.7), 2, 0.30),
        (.green, 5, 0.15),
        (.blue, 8, 0.10),
        (.black, 10, 0.05)
    ]

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
                }

                ForEach(bubbles) { bubble in
                    ZStack {
                        Circle()
                            .fill(bubble.color)

                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: bubbleSize * 0.25, height: bubbleSize * 0.25)
                            .offset(x: -bubbleSize * 0.2, y: -bubbleSize * 0.2)
                    }
                    .frame(width: bubbleSize, height: bubbleSize)
                    .position(bubble.position)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            pop(bubble)
                        }
                    }
                    .shadow(radius: 4)
                }
            }
            .overlay(alignment: .center) {
                if showingCountdown {
                    Text(preGameCount > 0 ? "\(preGameCount)" : "Go!")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(40)
                        .background(.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            // Clamp settings
            duration = min(max(duration, 5), 300)
            numberOfBubbles = min(max(numberOfBubbles, 1), Double(maxAllowedBubbles))

            score = 0
            timeRemaining = Int(duration)
            timerRunning = false
            bubbles.removeAll()

            lastBubbleColor = nil
            comboCount = 0

            // Countdown
            preGameCount = 3
            showingCountdown = true

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
                if preGameCount > 0 {
                    withAnimation(.easeOut(duration: 0.25)) {
                        preGameCount -= 1
                    }
                } else {
                    // Show "Go!" momentarily then start timer
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showingCountdown = false
                    }
                    t.invalidate()
                    timer = nil
                    timerRunning = true
                    startTimer()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            timerRunning = false
        }
    }

    // Timer logic

    func startTimer() {
        guard !showingCountdown else { return }

        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in

            if timeRemaining > 0 {
                timeRemaining -= 1
                refreshBubbles()
            } else {
                t.invalidate()
                Task { @MainActor in
                    timer?.invalidate()
                    timer = nil
                    timerRunning = false

                    ScoreManager.addScore(name: name, score: score)
                    path.append(Route.score(score))
                }
            }
        }
    }

    // Bubbel refresh logic

    func refreshBubbles() {
        if showingCountdown { return }

        let maxBubbles = Int(numberOfBubbles)

        // Never go > 60% of max
        let minKeep = Int(Double(maxBubbles) * 0.6)

        // Don't remove too many bubbles
        let currentCount = bubbles.count

        // Target after refresh (stable range)
        let target = Int.random(in: minKeep...maxBubbles)

        // How many to remove
        let removeCount = max(0, currentCount - target)

        for _ in 0..<removeCount {
            if let bubble = bubbles.randomElement(),
               let index = bubbles.firstIndex(of: bubble) {
                bubbles.remove(at: index)
            }
        }

        // Repopulate up to target
        var attempts = 0
        while bubbles.count < target && attempts < 500 {
            bubbles.append(randomBubble())
            attempts += 1
        }
    }

    func seedBubbles() {
        guard containerSize.width > 0 else { return }
        bubbles.removeAll()
        if showingCountdown { return }

        let target = Int.random(in: 1...Int(numberOfBubbles))

        var attempts = 0
        while bubbles.count < target && attempts < 500 {
            bubbles.append(randomBubble())
            attempts += 1
        }
    }

    func randomBubble() -> Bubble {

        let inset = bubbleSize / 2
        let type = randomBubbleType()

        var attempts = 0

        while attempts < 100 {
            let x = CGFloat.random(in: inset...(containerSize.width - inset))
            let y = CGFloat.random(in: inset...(containerSize.height - inset))

            let pos = CGPoint(x: x, y: y)

            if !isOverlapping(pos) {
                return Bubble(position: pos, color: type.color, size: bubbleSize, points: type.points)
            }

            attempts += 1
        }

        return Bubble(position: .zero, color: type.color, size: bubbleSize, points: type.points)
    }

    func isOverlapping(_ pos: CGPoint) -> Bool {
        for b in bubbles {
            let dx = b.position.x - pos.x
            let dy = b.position.y - pos.y
            if sqrt(dx*dx + dy*dy) < bubbleSize {
                return true
            }
        }
        return false
    }

    func randomBubbleType() -> (color: Color, points: Int, probability: Double) {
        let r = Double.random(in: 0...1)
        var c = 0.0

        for t in bubbleTypes {
            c += t.probability
            if r <= c { return t }
        }

        return bubbleTypes.last!
    }

    // Pop & combo

    func pop(_ bubble: Bubble) {

        if let idx = bubbles.firstIndex(of: bubble) {
            bubbles.remove(at: idx)

            if lastBubbleColor == bubble.color {
                comboCount += 1
            } else {
                comboCount = 1
            }

            lastBubbleColor = bubble.color

            var points = Double(bubble.points)

            if comboCount > 1 {
                points *= pow(1.5, Double(comboCount - 1))
            }

            score += Int(points.rounded())

            if score > highScore {
                highScore = score
            }
        }
    }
}

