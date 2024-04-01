//
//  ContentView.swift
//  To do list
//
//  Created by Larry on 3/28/24.
//


import SwiftUI

// Task Model
class TaskItem: Identifiable, ObservableObject {
    var id = UUID()
    @Published var task: String
    @Published var completed = false
    var priority: Priority
    var dueDate: Date?
    var category: Category?
    var tags: [String]?

    init(task: String, priority: Priority, dueDate: Date? = nil, category: Category? = nil, tags: [String]? = nil) {
        self.task = task
        self.priority = priority
        self.dueDate = dueDate
        self.category = category
        self.tags = tags
    }
}

enum Priority: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

enum Category: String, CaseIterable {
    case personal = "Personal"
    case work = "Work"
    case study = "Study"
}

// Task Store
class TaskStore: ObservableObject {
    @Published var tasks = [TaskItem]()

    func addTask(task: String, priority: Priority, dueDate: Date? = nil, category: Category? = nil, tags: [String]? = nil) {
        let newTask = TaskItem(task: task, priority: priority, dueDate: dueDate, category: category, tags: tags)
        tasks.append(newTask)
    }

    func deleteTask(at indices: [Int]) {
        indices.sorted(by: >).forEach { index in
            tasks.remove(at: index)
        }
    }

    func toggleTaskCompleted(task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].completed.toggle()
        }
    }
}

struct ContentView: View {
    @StateObject var taskStore = TaskStore()
    @State private var newTask = ""
    @State private var priority: Priority = .medium
    @State private var dueDate = Date()
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Add a new task", text: $newTask)
                        .padding()
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .padding()

                Picker("Priority", selection: $priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    .padding()

                List {
                    ForEach(taskStore.tasks.indices, id: \.self) { index in
                        TaskCell(taskItem: taskStore.tasks[index])
                    }
                    .onDelete(perform: { indexSet in
                        let indicesToDelete = Array(indexSet)
                        taskStore.deleteTask(at: indicesToDelete)
                    })
                }
                .navigationTitle("To-Do List")
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Delete Task"), message: Text("Are you sure you want to delete this task?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")) {
                    guard let indices = taskStore.tasks.indices.last else { return }
                    taskStore.deleteTask(at: [indices])
                })
            }
        }
    }

    func addTask() {
        guard !newTask.isEmpty else { return }
        taskStore.addTask(task: newTask, priority: priority, dueDate: dueDate)
        newTask = ""
    }
}

struct TaskCell: View {
    @ObservedObject var taskItem: TaskItem

    var body: some View {
        HStack {
            Button(action: {
                taskItem.completed.toggle()
            }) {
                Image(systemName: taskItem.completed ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(taskItem.completed ? .green : .primary)
            }
            .buttonStyle(BorderlessButtonStyle())

            Text(taskItem.task)
                .foregroundColor(taskItem.completed ? .gray : .primary)
                .strikethrough(taskItem.completed)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
