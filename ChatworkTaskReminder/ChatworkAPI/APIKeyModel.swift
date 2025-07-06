//
//  APIKeyModel.swift
//  ChatworkTaskReminder
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
            self.apiKey = apiKey
        } catch {
            print(error.localizedDescription)
            return nil
        }
        return apiKey
    }

    /// キーを保存（新規 / 更新）
    func save(_ key: String) throws {
        guard isValidAPIKey(key) else {
            throw APIKeyValidationError.invalidFormat
        }
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
    
    /// API キーの形式検証
    private func isValidAPIKey(_ key: String) -> Bool {
        // 空文字列チェック
        guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        // 長さチェック（一般的にAPI キーは20文字以上）
        guard key.count >= 20 && key.count <= 100 else {
            return false
        }
        
        // 英数字とハイフンのみ許可
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        return key.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
}

// MARK: - API Key Validation Error
enum APIKeyValidationError: LocalizedError {
    case invalidFormat
    case tooShort
    case tooLong
    case containsInvalidCharacters
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "APIキーの形式が正しくありません。英数字とハイフンのみを使用し、20文字以上100文字以下で入力してください。"
        case .tooShort:
            return "APIキーが短すぎます。20文字以上で入力してください。"
        case .tooLong:
            return "APIキーが長すぎます。100文字以下で入力してください。"
        case .containsInvalidCharacters:
            return "APIキーに無効な文字が含まれています。英数字とハイフンのみを使用してください。"
        }
    }
}
