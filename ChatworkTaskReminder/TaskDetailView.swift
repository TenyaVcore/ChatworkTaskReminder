import SwiftUI

struct TaskDetailView: View {
    let task: ChatworkTask
    
    var body: some View {
        Form {
            Section(header: Text("Task Info")) {
                HStack {
                    Text("Task ID")
                    Spacer()
                    Text("\(task.taskID)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Status")
                    Spacer()
                    Text(task.status.rawValue.capitalized)
                        .foregroundColor(task.status == .done ? .green : .orange)
                }
                
                HStack {
                    Text("Limit Type")
                    Spacer()
                    Text(task.limitType.rawValue.capitalized)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Room")) {
                HStack {
                    HStack(spacing: 8) {
                        AsyncImage(url: task.room.iconPath) { image in
                            image.resizable()
                                 .aspectRatio(contentMode: .fit)
                                 .frame(width: 20, height: 20)        // tweak size to taste
                                 .clipShape(Circle())                 // if your icons are square, drop this
                        } placeholder: {
                            ProgressView()
                                .frame(width: 20, height: 20)
                        }
                        Spacer()
                        Text(task.room.name)
                            .foregroundColor(.primary)
                    }
                }
            }

            Section(header: Text("Assigned By")) {
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        AsyncImage(url: task.assignedByAccount.avatarImageURL) { image in
                            image.resizable()
                                 .aspectRatio(contentMode: .fit)
                                 .frame(width: 20, height: 20)
                                 .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                                .frame(width: 20, height: 20)
                        }
                        Spacer()
                        Text(task.assignedByAccount.name)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Section(header: Text("Details")) {
                Text(task.body)
                    .padding(.vertical, 8)
                
                HStack {
                    Text("Due Date")
                    Spacer()
                    Text(Date(timeIntervalSince1970: task.limitTime).formatted())
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Task Details")
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTask = ChatworkTask(
            taskID: 12345,
            room: Room(
                roomID: 1,
                name: "Sample Room",
                iconPath: URL(string: "https://example.com/room.png")!
            ),
            assignedByAccount: Account(
                accountID: 1,
                name: "John Doe",
                avatarImageURL: URL(string: "https://example.com/avatar.png")!
            ),
            messageID: "msg123",
            body: "This is a sample task description with details about what needs to be done.",
            limitTime: Date().timeIntervalSince1970 + 86400,
            status: .open,
            limitType: .date
        )
        
        TaskDetailView(task: sampleTask)
    }
}
