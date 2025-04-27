//
//  Task.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import Foundation.NSDate

struct TaskEntity: Identifiable {
    var taskId: Int
    var roomId: Int
    var content: String
    var deadline: Date?
    var isCompleted = false

    var id: Int {
        taskId
    }
}
