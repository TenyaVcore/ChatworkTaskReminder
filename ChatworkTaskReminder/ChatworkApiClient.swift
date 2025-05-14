//
//  ChatworkApiClient.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/04/24.
//

import Foundation

class ChatworkAPIClient {

    private let baseURL = URL(string: "https://api.chatwork.com/v2")!
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    /// Chatwork APIクライアントを初期化します。
    /// - Parameter apiKey: Chatwork APIキー (`X-ChatWorkToken`)
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.decoder = JSONDecoder()
        // APIレスポンスのキー (snake_case) をSwiftのプロパティ (camelCase) に変換
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        // Unixタイムスタンプ (秒) をDateに変換する場合 (TaskのlimitTimeがDateなら必要)
        // self.decoder.dateDecodingStrategy = .secondsSince1970
    }

    // MARK: - Public API Methods

    /// 自分のタスク一覧を取得します。
    /// - Parameters:
    ///   - assignedByAccountID: タスク依頼者のアカウントID (オプション)
    ///   - status: タスクの状態 (open または done) (オプション)
    /// - Returns: タスクの配列
    /// - Throws: ChatworkAPIError
    func getMyTasks() async throws -> [ChatworkTask] {
        if APIKeyModel.shared.apiKey == nil {
            APIKeyModel.shared.load()
        }
        guard let apiKey = APIKeyModel.shared.apiKey else {
            print("apikey not set. getMyTasks failed.")
            APIKeyModel.shared.load()
            return []
        }
        let url = URL(string: "https://api.chatwork.com/v2/my/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "x-chatworktoken": apiKey
        ]

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([ChatworkTask].self, from: data)
    }

    /// チャットのタスクの完了状態を変更します。
    /// - Parameters:
    ///   - roomId: ルームID
    ///   - taskId: タスクID
    ///   - status: 新しい状態 (open または done)
    /// - Returns: 更新されたタスクID情報 (レスポンスが taskId のみの場合)
    /// - Throws: ChatworkAPIError
    func updateTaskStatus(roomId: Int, taskId: Int, status: TaskStatus) async throws -> UpdateTaskStatusResponse? {
        guard let apiKey = APIKeyModel.shared.apiKey else {
            return nil
        }
        let parameters = [
          "body": "done",
        ]
        let joinedParameters = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let postData = Data(joinedParameters.utf8)

        let url = URL(string: "https://api.chatwork.com/v2/rooms/\(roomId)/tasks/\(taskId)/status")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "content-type": "application/x-www-form-urlencoded",
          "x-chatworktoken": apiKey
        ]
        request.httpBody = postData
        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            let result = try JSONDecoder().decode(UpdateTaskStatusResponse.self, from: data)
            return result
        } catch {
            print(error)
            throw ChatworkAPIError.unknownError
        }
    }

    /// 現在のユーザー情報を取得します。
    /// - Returns: ユーザー情報
    /// - Throws: ChatworkAPIError
    func getUserInfo() async throws -> ChatworkUser {
        if APIKeyModel.shared.apiKey == nil {
            APIKeyModel.shared.load()
        }
        guard let apiKey = APIKeyModel.shared.apiKey else {
            throw ChatworkAPIError.invalidApiKey
        }

        let url = baseURL.appendingPathComponent("/me")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "x-chatworktoken": apiKey
        ]

        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ChatworkAPIError.requestFailed
        }

        return try decoder.decode(ChatworkUser.self, from: data)
    }
}
