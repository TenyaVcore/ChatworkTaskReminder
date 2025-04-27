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

    var body: some View {
        NavigationView {
            List {
                Text("ここにタスク一覧を表示")
            }
            .navigationTitle("Task一覧")
        }
        .onAppear {
            showAPIKeySheet = !keyModel.isRegistered
        }
        .onChange(of: keyModel.apiKey) { _ in
            // API キーが保存されたら自動的に閉じ、削除されたら再表示
            showAPIKeySheet = !keyModel.isRegistered
        }
        .sheet(isPresented: $showAPIKeySheet, content: {
            APIKeyView()
                .interactiveDismissDisabled()
        })
    }
}

struct TaskCell: View {
    let task: TaskEntity

    private var dueText: String? {
        task.deadline?.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.content)
                    .font(.body)
                Text("期限: \(dueText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // 今日が期限ならアイコン表示（例）
//            if Calendar.current.isDateInToday(task.deadline) {
//                Image(systemName: "exclamationmark.circle.fill")
//                    .foregroundColor(.red)
//            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskView()
}
