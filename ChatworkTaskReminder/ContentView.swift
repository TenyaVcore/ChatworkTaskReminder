//
//  ContentView.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TaskView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Task")
                }
            SettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Setting")
                }
        }
    }
}

#Preview {
    ContentView()
}
