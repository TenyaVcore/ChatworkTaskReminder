//
//  SettingView.swift
//  ChatworkTaskRemider
//
//  Created by Tagawa Nobuya on 2025/04/25.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "gear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("user name")
                    .font(.title)
            }

            List {
                Text("api key変更")
            }
        }


    }
}

#Preview {
    SettingView()
}
