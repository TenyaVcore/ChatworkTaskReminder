//
//  TaskView.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/04/25.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject private var keyModel: APIKeyModel = .shared
    @ObservedObject private var taskModel = TaskModel.shared

    var body: some View {
        NavigationView {
            List(taskModel.tasks) { task in
                NavigationLink {
                    TaskDetailView(task: task)
                } label: {
                    TaskCell(task: task)
                }

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
            if keyModel.isRegistered {
                await taskModel.refresh()
            }
        }

    }
}

#Preview {
    TaskView()
}
