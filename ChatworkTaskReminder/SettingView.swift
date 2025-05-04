//
//  SettingView.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/25.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var apiKeyModel = APIKeyModel.shared
    @State private var showingConfirmAlert = false
    @State private var showingResultAlert = false
    @State private var resultAlertMessage = ""
    @State private var resultAlertTitle = ""

    var body: some View {
        NavigationView {
            List {
                Button(role: .destructive) {
                    showingConfirmAlert = true
                } label: {
                    Text("APIKeyを削除")
                }
            }
            .navigationTitle("Settings")
            .alert("確認", isPresented: $showingConfirmAlert) {
                Button("削除", role: .destructive) {
                    do {
                        try apiKeyModel.delete()
                        TaskModel.shared.deleteAll()
                    } catch {
                        resultAlertTitle = "エラー"
                        resultAlertMessage = "APIキーの削除に失敗しました"
                        showingResultAlert = true
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("APIキーを削除してもよろしいですか？")
            }
        }
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingView()
        }
    }
}
