//
//  APIKeyView.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import SwiftUI

struct APIKeyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) var openURL
    @State private var apiKey: String = ""
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false

    var body: some View {
        VStack(spacing: 24) {
            Text("API Keyを入力してください")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 12) {
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .frame(maxWidth: .infinity)

                PasteButton(payloadType: String.self) { strings in
                    if let first = strings.first {
                        apiKey = first
                    }
                }
                .buttonStyle(.bordered)
            }

            Button {
                do {
                    try APIKeyModel.shared.save(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                } catch {
                    print(error)
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            } label: {
                Text("保存")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .padding()

        Divider()

        Button {
                    openURL(URL(string: "https://qiita.com/SNQ-2001")!)
                } label: {
                    Text("API Keyの確認方法")
                        .font(.title3)
                        .padding(10)
                }
        .alert("エラー", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    @Previewable @State var isAPIKeysaved: Bool = false
    APIKeyView()
}
