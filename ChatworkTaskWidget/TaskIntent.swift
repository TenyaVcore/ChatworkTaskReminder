//
//  TaskIntent.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/04/24.
//

import SwiftUI
import AppIntents
import WidgetKit

struct TaskIntent: AppIntent {
    static var title: LocalizedStringResource = "taskIntent"
    @Parameter(title: "taskId")
    var taskId: Int
    @Parameter(title: "roomId")
    var roomId: Int

    init() {}

    init(taskId: Int, roomId: Int) {
        self.taskId = taskId
        self.roomId = roomId
    }

    func perform() async throws -> some IntentResult {
        let client = ChatworkAPIClient()
        let _ = try? await client.updateTaskStatus(roomId: roomId, taskId: taskId, status: .open)
        return .result()
    }
}

struct reloadIntent: AppIntent {
    static var title: LocalizedStringResource = "reloadIntent"
    init() {
    }
    func perform() async throws -> some IntentResult {
        return .result()}
}

struct cancelIntent: AppIntent {
    static var title: LocalizedStringResource = "cancelIntent"
    init() {
    }
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
