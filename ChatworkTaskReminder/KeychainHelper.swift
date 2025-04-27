//
//  KeychainHelper.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import Foundation

final class KeychainHelper {
    private static let service = "nobuya.ChatworkTaskRemider"

    func save(data: Data, account: String) -> Bool {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: KeychainHelper.service,
            kSecAttrAccount: account
        ] as CFDictionary

        let matchingStatus: OSStatus = SecItemCopyMatching(query, nil)
        switch matchingStatus {
        case errSecItemNotFound:
            // 見つからなかったら保存
            let status = SecItemAdd(query, nil)
            return status == noErr
        case errSecSuccess:
            SecItemUpdate(
                query,
                [kSecValueData as String: data] as CFDictionary)
            return true
        default:
            return false
        }
    }

    func read(account: String) -> String? {
        let query = [
            kSecAttrService: KeychainHelper.service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)

        if let data = (result as? Data) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    func delete(account: String) -> Bool {
        let query = [
            kSecAttrService: KeychainHelper.service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary

        let status = SecItemDelete(query)
        return status == noErr
    }
}
