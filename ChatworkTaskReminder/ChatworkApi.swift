//
//  ChatworkApi.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/25.
//

import Foundation

// MARK: - データモデル
struct ChatworkTask: Decodable {
    let taskID: Int
    let room: Room
    let assignedByAccount: Account
    let messageID: String
    let body: String
    let limitTime: TimeInterval
    let status: TaskStatus
    let limitType: LimitType

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

struct Room: Decodable {
    let roomID: Int
    let name: String
    let iconPath: URL

    enum CodingKeys: String, CodingKey {
        case roomID  = "room_id"
        case name
        case iconPath = "icon_path"
    }
}

struct Account: Decodable {
    let accountID: Int
    let name: String
    let avatarImageURL: URL

    enum CodingKeys: String, CodingKey {
        case accountID  = "account_id"
        case name
        case avatarImageURL = "avatar_image_url"
    }
}

enum TaskStatus: String, Decodable {
    case open
    case done
}

enum LimitType: String, Decodable {
    case date
    case none
}

// タスク状態更新APIのレスポンス
public struct UpdateTaskStatusResponse: Codable {
    let taskId: String

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
    }
}

// APIエラーレスポンス
struct ChatworkAPIErrorResponse: Codable, Error {
    let errors: [String]
}

// MARK: - APIクライアント用エラー定義
enum ChatworkAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case apiError(ChatworkAPIErrorResponse)
    case decodingError(Error)
    case unexpectedStatusCode(Int)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです。"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .apiError(let response):
            return "APIエラー: \(response.errors.joined(separator: ", "))"
        case .decodingError(let error):
            // デコードエラーの詳細を表示するとデバッグに役立つ
            if let decodingError = error as? DecodingError {
                 return "デコードエラー: \(decodingError.detailedDescription)"
            }
            return "デコードエラー: \(error.localizedDescription)"
        case .unexpectedStatusCode(let code):
            return "予期せぬHTTPステータスコード: \(code)"
        case .unknownError:
            return "不明なエラーが発生しました。"
        }
    }
}

// DecodingError の詳細説明を取得する拡張 (デバッグ用)
extension DecodingError {
    var detailedDescription: String {
        switch self {
        case .typeMismatch(let type, let context):
            return "Type mismatch for type \(type) at path \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Value not found for type \(type) at path \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Key not found: \(key.stringValue) at path \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Data corrupted at path \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
        @unknown default:
            return localizedDescription
        }
    }
}
