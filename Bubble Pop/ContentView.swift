//
//  ContentView.swift
//  Bubble Pop
//
//  Created by rentamac on 4/22/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                
                Text("Bubble Pop")
                    .padding(50)
                    .font(.largeTitle)
                    .bold()
                
                NavigationLink("Play", value: "play")
                    .padding(10)
                
                NavigationLink("Settings", value: "settings")
                    .padding(10)
            }
            .navigationDestination(for: String.self) { value in
                if value == "play" {
                    PlayView(path: $path)
                } else if value == "settings" {
                    SettingsView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
