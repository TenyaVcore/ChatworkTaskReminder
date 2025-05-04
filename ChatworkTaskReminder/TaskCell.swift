//
//  TaskCell.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import SwiftUI

struct TaskCell: View {
    let task: ChatworkTask

    private var dueText: String {
        task.limitTime.formatted()
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.body)
                    .font(.body)
                    .lineLimit(3)
                Text("依頼者: \(task.assignedByAccount.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("期限: \(task.limitTime.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
//            今日が期限ならアイコン表示
            if Calendar.current.isDateInToday(task.limitTime.asDate) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskCell(
        task: ChatworkTask(
            taskID: 22,
            room: Room(
                roomID: 22,
                name: "room name",
                iconPath: URL(filePath: "https://example.com/icon.png")!
            ),
            assignedByAccount: Account(
                accountID: 33,
                name: "namae",
                avatarImageURL: URL(filePath: "https://example.com/icon.png")!
            ),
            messageID: "message",
            body: "body",
            limitTime: 5666,
            status: .open,
            limitType: .date
        )
    )
}
