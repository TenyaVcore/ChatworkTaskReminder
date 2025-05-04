//
//  ContentView.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var keyModel: APIKeyModel = .shared
    @State private var showAPIKeySheet = false
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
        .task {
            keyModel.load()
            showAPIKeySheet = !keyModel.isRegistered
        }
        .onChange(of: keyModel.apiKey) { _ in
            // API キーが保存されたら自動的に閉じ、削除されたら再表示
            showAPIKeySheet = !keyModel.isRegistered
        }
        .sheet(isPresented: $showAPIKeySheet) {
            APIKeyView()
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    ContentView()
}
