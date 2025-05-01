//
//  TaskView.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/25.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject private var keyModel: APIKeyModel = .shared
    @State private var showAPIKeySheet = false
    @ObservedObject private var taskModel = TaskModel.shared

    var body: some View {
        NavigationView {
            List(taskModel.tasks) { task in
                TaskCell(task: task)
            }
            .navigationTitle("Task一覧")
            .overlay {
                if taskModel.tasks.isEmpty {
                    ContentUnavailableView("タスクがありません", systemImage: "checkmark.circle")
                }
            }
        }
        .refreshable {
            if keyModel.isRegistered {
                await taskModel.refresh()
            }
        }
        .task {
            showAPIKeySheet = !keyModel.isRegistered
            if keyModel.isRegistered {
                await taskModel.refresh()
            }
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
    TaskView()
}
