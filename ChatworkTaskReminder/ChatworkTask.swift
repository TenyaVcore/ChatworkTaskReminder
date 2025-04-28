//
//  Task.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import Foundation.NSDate

struct ChatworkTask: Codable, Identifiable {
    let taskID: Int
    let room: Room
    let assignedByAccount: Account
    let messageID: String
    let body: String
    let limitTime: TimeInterval
    let status: TaskStatus
    let limitType: LimitType

    var id: Int {
        taskID
    }

    enum CodingKeys: String, CodingKey {
            case taskID  = "task_id"
            case room
            case assignedByAccount = "assigned_by_account"
            case messageID = "message_id"
            case body
            case limitTime = "limit_time"
            case status
            case limitType = "limit_type"
        }
}

struct Room: Codable {
    let roomID: Int
    let name: String
    let iconPath: URL

    enum CodingKeys: String, CodingKey {
        case roomID  = "room_id"
        case name
        case iconPath = "icon_path"
    }
}

struct Account: Codable {
    let accountID: Int
    let name: String
    let avatarImageURL: URL

    enum CodingKeys: String, CodingKey {
        case accountID  = "account_id"
        case name
        case avatarImageURL = "avatar_image_url"
    }
}

enum TaskStatus: String, Codable {
    case open
    case done
}

enum LimitType: String, Codable {
    case date
    case none
}
