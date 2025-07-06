//
//  TaskModel.swift
//  ChatworkTaskReminder
//
//  Created by Tagawa Nobuya on 2025/04/27.
//

import Foundation


final class TaskModel: ObservableObject {
    static let shared = TaskModel()

    @Published private(set) var tasks: [ChatworkTask] = []
    @Published private(set) var error: Error?
    @Published private(set) var isLoading = false

    private let cacheURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        // キャッシュファイル (Library/Caches/tasks.json)
        cacheURL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tasks.json")
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        loadCache()
    }

    // MARK: -  Public API

    @MainActor
    /// API から最新タスクを取得し、キャッシュに保存
    func refresh() async {
        isLoading = true
        error = nil
        
        do {
            tasks = try await fetchFromAPI()
            saveCache()
        } catch {
            print("Task fetch failed:", error)
            self.error = error
        }
        
        isLoading = false
    }

    func add(_ task: ChatworkTask) {
        tasks.append(task)
        saveCache()
    }

    func deleteAll() {
        tasks.removeAll()
        saveCache()
    }
    
    func clearError() {
        error = nil
    }

    // MARK: Private helpers

    private func fetchFromAPI() async throws -> [ChatworkTask] {
        let client = ChatworkAPIClient()
        return try await client.getMyTasks()
    }

    private func saveCache() {
        guard let data = try? encoder.encode(tasks) else { return }
        try? data.write(to: cacheURL, options: .atomic)
    }

    private func loadCache() {
        guard let data = try? Data(contentsOf: cacheURL),
              let cached = try? decoder.decode([ChatworkTask].self, from: data) else { return }
        tasks = cached
    }
}
