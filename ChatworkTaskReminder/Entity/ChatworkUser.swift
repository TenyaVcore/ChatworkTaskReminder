//
//  ChatworkUser.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/05/14.
//

struct ChatworkUser: Codable {
    let accountId: Int
    let name: String
    let avatarImageUrl: String?
    let organization: String?
    let department: String?
    let title: String?
    let url: String?
    let introduction: String?
    let mail: String?
    let telOrganization: String?
    let telExtension: String?
    let telMobile: String?
    let skype: String?
    let facebook: String?
    let twitter: String?
    let loginMail: String?
}