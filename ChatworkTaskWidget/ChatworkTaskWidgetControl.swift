//
//  ChatworkTaskWidgetControl.swift
//  ChatworkTaskWidget
//
//  Created by Tagawa Nobuya on 2025/04/23.
//

import AppIntents
import SwiftUI
import WidgetKit

struct ChatworkTaskWidgetControl: ControlWidget {
    static let kind: String = "nobuya.ChatworkTaskRemider.ChatworkTaskWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value.isRunning,
                action: StartTimerIntent(value.name)
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension ChatworkTaskWidgetControl {
    struct Value {
        var isRunning: Bool
        var name: String
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: TimerConfiguration) -> Value {
            ChatworkTaskWidgetControl.Value(isRunning: false, name: configuration.timerName)
        }

        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            let isRunning = true // Check if the timer is running
            return ChatworkTaskWidgetControl.Value(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

struct TimerConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Timer Name Configuration"

    @Parameter(title: "Timer Name", default: "Timer")
    var timerName: String
}

struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "CompleteTask"
//    @Parameter(title: "Task ID")

    func perform() async throws -> some IntentResult {
        WidgetTask.completeTask()
        return .result()
    }
}

final class WidgetTask {
    private static let sharedDefaults: UserDefaults = UserDefaults(suiteName: "chatwork.taskReminder.com")!

    struct TaskInfo {
        let title: String
        let description: String
        let dueDate: Date
    }

    static func completeTask() {
        // TODO: send request & refresh list
//        var count = sharedDefaults.integer(forKey: "count")
//        count += 1
//        sharedDefaults.set(count, forKey: "count")
    }

    static func currentTasks() -> [TaskInfo] {
        // TODO: fetch tasks
        []
    }
}
