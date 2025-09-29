import SwiftUI
import Combine
import SwiftData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @State private var selection: Tabkey = .student
    @State private var versionStore = RoutineVersionStore()
    
    private let webService = WebService()
    
    var body: some View {
        TabView(selection: $selection) {
            Tab ("Student", systemImage: "graduationcap", value: Tabkey.student) {
                StudentView()
            }
            
            Tab ("Teacher", systemImage: "person.crop.rectangle.stack", value: Tabkey.teacher) {
                TeacherView()
            }
            
            Tab ("EmptyRoom", systemImage: "square.stack", value: Tabkey.emptyRoom) {
                NavigationStack {
                    VStack {
                            // Your content here
                    }
                    .navigationTitle("Hello")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Action") {
                                    // Action
                            }
                        }
                    }
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Color(hue: 0.5, saturation: 0.8, brightness: colorScheme == .light ? 0.65 : 0.75))
        .task {
            await webService.fetchVersion(versionStore: versionStore, modelContext: modelContext)
        }
    }
}

private enum Tabkey: Hashable {
    case student
    case teacher
    case emptyRoom
    case timepicker
}

#Preview {
    ContentView()
        .modelContainer(for: RoutineDO.self, inMemory: true)
}

