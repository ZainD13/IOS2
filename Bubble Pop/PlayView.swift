//
//  PlayView.swift
//  Bubble Pop
//
//  Created by rentamac on 4/22/26.
//

import SwiftUI

struct PlayView: View {
    
    @Binding var path: NavigationPath
    
    @AppStorage("duration") private var duration: Double = 45
    
    @State private var timeRemaining: Int = 45
    @State private var timerRunning = false
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Time: \(timeRemaining)")
                
                Spacer()
                
                Text("Score: 0")
                
                Spacer()
                
                Text("High: 0")
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            timeRemaining = Int(duration)
            startTimer()
        }
    }
    
    func startTimer() {
        guard !timerRunning else { return }
        timerRunning = true
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                timerRunning = false
                
                // Exit home
                path = NavigationPath()
            }
        }
    }
}

#Preview {
    PlayView(path: .constant(NavigationPath()))
}
