//
//  Untitled.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/24.
//

import Foundation

// MARK: - データモデル

// タスク情報
struct Task: Codable, Identifiable {
    let id: Int // task_id を id として使うため Identifiable に適合
    let roomId: Int
    let account: Account
    let assignedByAccount: Account
    let messageId: String // メッセージIDは数値だが非常に大きくなる可能性があるのでStringが安全
    let body: String
    let limitTime: Int // Unix time
    let status: TaskStatus
    let limitType: String // 'none', 'date', 'time'

    enum CodingKeys: String, CodingKey {
        case id = "task_id" // APIのキー名をSwiftのプロパティ名にマッピング
        case roomId = "room_id"
        case account
        case assignedByAccount = "assigned_by_account"
        case messageId = "message_id"
        case body
        case limitTime = "limit_time"
        case status
        case limitType = "limit_type"
    }
}

// アカウント情報 (Task内で使用)
struct Account: Codable {
    let accountId: Int
    let name: String
    let avatarImageUrl: URL // URL型としてデコード

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case name
        case avatarImageUrl = "avatar_image_url"
    }
}

// タスク状態 (Codableに準拠したEnum)
enum TaskStatus: String, Codable {
    case open
    case done
}

// タスク状態更新APIのレスポンス
struct UpdateTaskStatusResponse: Codable {
    let taskId: String // ドキュメントではstringだが、実際は数値かも？確認必要。デコード時にエラーになる場合はIntにする。

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id" // APIドキュメントでは 'task_ids' と複数形だが、単一更新なので単数形のはず？ 要確認
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
