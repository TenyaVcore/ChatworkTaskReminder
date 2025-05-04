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
            .frame(width: 15)

            VStack {
                ForEach(entry.taskList.prefix(limit)) { task in
                    TaskWidgetCell(task: task)
                }
            }
        }
        .containerBackground(for: .widget) {
            ContainerRelativeShape().foregroundStyle(AnyShapeStyle(.white))
        }
    }
}

struct TaskWidgetCell: View {
    let task: ChatworkTask

    private func formatDeadline(time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        return date
            .formatted(
                Date
                    .FormatStyle(date: .numeric, time: .omitted)
                    .year(.twoDigits)
                    .day()
            )
    }

    private func formatDeadlineTime(time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let time = date.formatted(Date.FormatStyle(date: .omitted, time: .shortened))
        return time
    }


    private func deadlineColor(time: TimeInterval) -> Color {
        let date = Date(timeIntervalSince1970: time)
        let now = Date()
        let calendar = Calendar.current

        if date < now {
            return .red
        } else if calendar.isDateInToday(date) || calendar.isDateInTomorrow(date) {
            return .orange
        } else {
            return .secondary
        }
    }

    var body: some View {
        Button(intent: TaskIntent(taskId: task.taskID, roomId: task.room.roomID)) {
            HStack(alignment: .center) {
                Text(task.body)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.black)

                Spacer() // Pushes the deadline text to the right

                if task.limitType == .date {
                    VStack {
                        Text(formatDeadline(time: task.limitTime))
                            .font(.caption)
                            .foregroundColor(deadlineColor(time: task.limitTime))

                        Text(formatDeadlineTime(time: task.limitTime))
                            .font(.caption)
                            .foregroundColor(deadlineColor(time: task.limitTime))
                    }
                }
            }
        }
    }
}


//#Preview(as: .systemMedium) { // Preview the widget in medium size
//    ChatworkTaskWidget() // The main widget struct
//} timeline: {
//    // Provide sample data for the preview timeline
//    TaskEntry(date: Date(), taskList: Provider.sampleTasks)
//    TaskEntry(date: Date().addingTimeInterval(3600), taskList: Provider.sampleTasks.dropFirst()) // Example of a future entry
//}

struct TaskEntry: TimelineEntry {
    let date: Date = .now
    let taskList: [ChatworkTask]
}

struct Provider: TimelineProvider {
    let client = ChatworkAPIClient()

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

