//
//  TimeInterval＋.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/04/28.
//

import Foundation.NSDate

extension TimeInterval {
    /// 好きなフォーマット文字列を返すユーティリティ
    /// - Parameters:
    ///   - format: DateFormatter の書式。デフォルトは "yyyy/MM/dd HH:mm:ss"
    ///   - timeZone: タイムゾーン。デフォルトは .current
    ///   - locale: ロケール。デフォルトは .current
    func formatted(_ format: String = "yyyy/MM/dd HH:mm:ss",
                   timeZone: TimeZone = .current,
                   locale: Locale = .current) -> String {
        if self == 0 {
            return "期限なし"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        formatter.locale = locale
        return formatter.string(from: Date(timeIntervalSince1970: self))
    }

    /// 秒単位の UNIX タイムスタンプを Date に変換
    var asDate: Date {
        Date(timeIntervalSince1970: self)
    }
}
