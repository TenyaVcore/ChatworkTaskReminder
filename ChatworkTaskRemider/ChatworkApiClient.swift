//
//  ChatworkApiClient.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/24.
//

import Foundation

// MARK: - Chatwork API Client Class

class ChatworkAPIClient {

    private let baseURL = URL(string: "https://api.chatwork.com/v2")!
    private var apiKey: String = "38e3989ad77553c8cbca68f6f20e5ff4"
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    /// Chatwork APIクライアントを初期化します。
    /// - Parameter apiKey: Chatwork APIキー (`X-ChatWorkToken`)
    init(apiKey: String, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
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
    func getMyTasks(assignedByAccountID: Int? = nil, status: TaskStatus? = nil) async throws -> [Task] {
        var queryItems = [URLQueryItem]()
        if let accountID = assignedByAccountID {
            queryItems.append(URLQueryItem(name: "assigned_by_account_id", value: String(accountID)))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }

        return try await request(endpoint: "/my/tasks", method: "GET", queryItems: queryItems)
    }

    /// チャットのタスクの完了状態を変更します。
    /// - Parameters:
    ///   - roomId: ルームID
    ///   - taskId: タスクID
    ///   - status: 新しい状態 (open または done)
    /// - Returns: 更新されたタスクID情報 (レスポンスが taskId のみの場合)
    /// - Throws: ChatworkAPIError
    func updateTaskStatus(roomId: Int, taskId: Int, status: TaskStatus) async throws -> UpdateTaskStatusResponse {
        let endpoint = "/rooms/\(roomId)/tasks/\(taskId)/status"
        // リクエストボディは "body=新しい状態" という形式の application/x-www-form-urlencoded
        let bodyString = "body=\(status.rawValue)"
        guard let bodyData = bodyString.data(using: .utf8) else {
            // 通常ここには来ないはずだが念のため
            throw ChatworkAPIError.unknownError
        }

        var headers = defaultHeaders()
        headers["Content-Type"] = "application/x-www-form-urlencoded" // Content-Typeを指定

        return try await request(endpoint: endpoint, method: "PUT", headers: headers, body: bodyData)
    }

    // MARK: - Private Helper Methods

    /// デフォルトのHTTPヘッダーを作成します (APIキーを含む)
    private func defaultHeaders() -> [String: String] {
        return ["X-ChatWorkToken": apiKey]
    }

    /// APIリクエストを送信し、レスポンスをデコードする共通メソッド
    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        headers: [String: String]? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) async throws -> T {

        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false) else {
            throw ChatworkAPIError.invalidURL
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw ChatworkAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        // ヘッダーの設定 (デフォルトヘッダー + 追加ヘッダー)
        let requestHeaders = defaultHeaders().merging(headers ?? [:]) { (_, new) in new }
        requestHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.httpBody = body

        // デバッグ用: リクエスト内容を出力
        // print("Request URL: \(url)")
        // print("Request Method: \(method)")
        // print("Request Headers: \(requestHeaders)")
        // if let body = body, let bodyStr = String(data: body, encoding: .utf8) {
        //     print("Request Body: \(bodyStr)")
        // }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw ChatworkAPIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatworkAPIError.unknownError
        }

        // デバッグ用: レスポンス内容を出力
        // print("Response Status Code: \(httpResponse.statusCode)")
        // if let responseStr = String(data: data, encoding: .utf8) {
        //     print("Response Body: \(responseStr)")
        // }


        // ステータスコードチェック
        switch httpResponse.statusCode {
        case 200...299: // 成功
            do {
                // レスポンスボディが空の場合 (例: 204 No Content) でも T が Optional<Something> や Void のような場合に成功させる
                if data.isEmpty, let empty = EmptyResponse() as? T {
                     return empty // 空レスポンスが期待される場合の処理 (今回は該当しにくい)
                }
                let decodedObject = try decoder.decode(T.self, from: data)
                return decodedObject
            } catch {
                print("--- Decoding Error Details ---")
                if let decodingError = error as? DecodingError {
                    print(decodingError.detailedDescription)
                } else {
                    print(error.localizedDescription)
                }
                 print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode as UTF-8")")
                 print("-----------------------------")
                throw ChatworkAPIError.decodingError(error)
            }
        case 400...599: // クライアントエラー or サーバーエラー
            // エラーレスポンスをデコード試行
            if let errorResponse = try? decoder.decode(ChatworkAPIErrorResponse.self, from: data) {
                throw ChatworkAPIError.apiError(errorResponse)
            } else {
                // エラーレスポンスのデコードに失敗した場合
                 print("Failed to decode API error response. Status Code: \(httpResponse.statusCode)")
                 print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode as UTF-8")")
                throw ChatworkAPIError.unexpectedStatusCode(httpResponse.statusCode)
            }
        default: // その他のステータスコード
            throw ChatworkAPIError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    // 空のレスポンスボディを表すためのダミー構造体 (必要に応じて使用)
    private struct EmptyResponse: Decodable {}
}
