//
//  APIKeyModel.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import Foundation

/// TaskReminder 用 API キーを Keychain & メモリキャッシュで管理
final class APIKeyModel: ObservableObject {
    @Published private(set) var apiKey: String?
    private let account = "CWAPIKey"
    private let keychain = KeychainHelper()

    static let shared = APIKeyModel()

    private init() {
        load()
        print("API Key Model initialized. ")
        print("API Key: \(String(describing: self.apiKey))")
    }
    

    /// キーの読込（キャッシュに展開）
    @discardableResult
    func load() -> String? {
        do {
            let apiKey = try keychain.readApiKey()
        } catch {
            print(error.localizedDescription)
            return nil
        }
        return apiKey
    }

    /// キーを保存（新規 / 更新）
    func save(_ key: String) throws {
        try keychain.saveApiKey(apiKey: key)
        apiKey = key
    }

    /// キーを削除
    func delete() throws {
        try keychain.deleteApiKey()
        apiKey = nil
    }

    // true なら既に保存済み
    var isRegistered: Bool { apiKey != nil }
}
