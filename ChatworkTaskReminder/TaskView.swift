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
    @State private var showingErrorAlert = false

    var body: some View {
        NavigationView {
            Group {
                if taskModel.isLoading {
                    ProgressView("タスクを読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(taskModel.tasks) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            TaskCell(task: task)
                        }
                    }
                    .overlay {
                        if taskModel.tasks.isEmpty && !taskModel.isLoading {
                            ContentUnavailableView("タスクがありません", systemImage: "checkmark.circle")
                        }
                    }
                }
            }
            .navigationTitle("Task一覧")
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
        .alert("エラー", isPresented: $showingErrorAlert) {
            Button("リトライ") {
                Task {
                    await taskModel.refresh()
                }
            }
            Button("閉じる", role: .cancel) {
                taskModel.clearError()
            }
        } message: {
            if let error = taskModel.error {
                Text(errorMessage(for: error))
            }
        }
        .onChange(of: taskModel.error) { error in
            showingErrorAlert = error != nil
        }

    }
    
    private func errorMessage(for error: Error) -> String {
        if let chatworkError = error as? ChatworkAPIError {
            return chatworkError.localizedDescription
        }
        return "ネットワークエラーが発生しました。インターネット接続を確認してください。"
    }
}

#Preview {
    TaskView()
}
