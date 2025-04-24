//
//  ChatworkTaskWidget.swift
//  ChatworkTaskWidget
//
//  Created by Tagawa Nobuya on 2025/04/23.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct ChatworkTaskWidgetEntryView : View {
    var entry: Provider.Entry


    var body: some View {
        VStack {
            TaskWidgetCell(taskName: "task1")
            TaskWidgetCell(taskName: "task2")
            TaskWidgetCell(taskName: "task3")
        }
    }
}

struct ChatworkTaskWidget: Widget {
    let kind: String = "ChatworkTaskWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ChatworkTaskWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct TaskWidgetCell: View {
    let taskName: String
    @State private var isChecked: Bool = false
    var body: some View {
        Button(intent: CompleteTaskIntent()) {
            HStack {
                Text(taskName)
                Spacer()
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .foregroundColor(.primary)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
}

#Preview(as: .systemSmall) {
    ChatworkTaskWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
}
