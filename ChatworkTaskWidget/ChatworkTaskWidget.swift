//
//  ChatworkTaskWidget.swift
//  ChatworkTaskWidget
//
//  Created by Tagawa Nobuya on 2025/04/23.
//

import WidgetKit
import SwiftUI
import AppIntents

struct ChatworkTaskWidget: Widget {
    let kind: String = "TaskWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TaskWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Task Widget")
        .description("interactive widget.")
    }
}

struct TaskWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    private var limit: Int {
            switch family {
            case .systemSmall:        3
            case .systemMedium:       3
            case .systemLarge:        7
            case .systemExtraLarge:  9
            case .accessoryCircular,
                 .accessoryRectangular,
                 .accessoryInline:    1
            @unknown default:         1
            }
        }
    var entry: Provider.Entry
    var body: some View {
        HStack {
            VStack {
                Button(intent: reloadIntent()) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                }

                Button(intent: cancelIntent()) {
                    Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                }
            }
            VStack {
                ForEach(entry.taskList.prefix(limit)) { task in
                    TaskWidgetCell(task: task)
                }
            }
        }
    }
}

struct TaskWidgetCell: View {
    let task: ChatworkTask
    @State private var isChecked: Bool = false
    var body: some View {
        Button(intent: TaskIntent(taskId: task.taskID, roomId: task.room.roomID)) {
            HStack {
                Text(task.body)
                    .lineLimit(1)
                    .font(.caption)
                Spacer()
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct TaskEntry: TimelineEntry {
    let date: Date = .now
    let taskList: [ChatworkTask]
}

struct Provider: TimelineProvider {
    let client = ChatworkAPIClient(
        apiKey: "38e3989ad77553c8cbca68f6f20e5ff4"
    )
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(taskList: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        // TODO: fetch data from local
        let entry = TaskEntry(taskList: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        Task {
            do {
                let result = try await client.getMyTasks()
                // TODO: save data to local
                print(result)
                let latestEntries = [TaskEntry(taskList: result)]
                let timeline = Timeline(entries: latestEntries, policy: .atEnd)
                completion(timeline)
            } catch {
                print("error\(error)")
            }
        }
    }
}

