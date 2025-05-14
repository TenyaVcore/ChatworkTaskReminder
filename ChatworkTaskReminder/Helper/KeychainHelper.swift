//
//  KeychainHelper.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import Foundation
import KeychainAccess

final class KeychainHelper {
    private let service = "nobuya.ChatworkTaskReminder"
    private let group = "P4P28KTQQK.nobuya.ChatworkTaskReminder.WidgetGroup"

    func saveApiKey(apiKey: String) throws {
        let keychain = Keychain(service: service, accessGroup: group)
        try keychain.set(apiKey, key: "apiKey")
    }

    func readApiKey() throws -> String {
        let keychain = Keychain(service: service, accessGroup: group)
        let apiKey = try keychain.getString("apiKey")
                if let apiKey {
                    print("apiKeyの値を取得しました: \(apiKey)")
                    return apiKey
                } else {
                    print("apiKeyに対応する値が見つかりませんでした。")
                    throw KeychainError.itemNotFound(key: "apiKey")
                }
    }

    func deleteApiKey() throws {
        let keychain = Keychain(service: service, accessGroup: group)
        try keychain.remove("apiKey")
    }
}

enum KeychainError: Error, LocalizedError {
    case itemNotFound(key: String)
    case unexpectedError(message: String)

    var errorDescription: String? {
        switch self {
        case .itemNotFound(let key):
            return "キー '\(key)' に対応する値が Keychain に見つかりませんでした。"
        case .unexpectedError(let message):
            return "予期せぬ Keychain エラーが発生しました: \(message)"
        }
    }
}
