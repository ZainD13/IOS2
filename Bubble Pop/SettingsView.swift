//
//  SettingsView.swift
//  Bubble Pop
//
//  Created by rentamac on 4/22/26.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("numberOfBubbles") private var numberOfBubbles: Double = 10
    @AppStorage("duration") private var duration: Double = 45

    var body: some View {
        VStack {
            
            Spacer()

            VStack(spacing: 30) {

                VStack {
                    Text("Number of Bubbles: \(Int(numberOfBubbles))")

                    Slider(value: $numberOfBubbles, in: 1...15, step: 1)
                }

                VStack {
                    Text("Duration: \(Int(duration)) seconds")

                    Slider(value: $duration, in: 30...60, step: 1)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
