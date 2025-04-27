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
    }

    /// キーの読込（キャッシュに展開）
    @discardableResult
    func load() -> String? {
        if let key = keychain.read(account: account){
            apiKey = key
        }
        return apiKey
    }

    /// キーを保存（新規 / 更新）
    @discardableResult
    func save(_ key: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        let ok = keychain.save(data: data, account: account)
        if ok { apiKey = key }
        return ok
    }

    /// キーを削除
    @discardableResult
    func delete() -> Bool {
        let ok = keychain.delete(account: account)
        if ok { apiKey = nil }
        return ok
    }

    // true なら既に保存済み
    var isRegistered: Bool { apiKey != nil }
}
