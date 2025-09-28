//import SwiftUI
//import Combine
//
//@MainActor
//class RoutineViewModel: ObservableObject {
//    @Published var routines: [Routine] = []
//    @Published var isLoading = true
//    @Published var errorMessage: String?
//    
//    func fetchRoutines() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            let response = try await fetchRoutineFromApi()
//            routines = response 
//        } catch {
//            print("Failed to fetch routines:", error)
//            errorMessage = "Failed to load routines: \(error.localizedDescription)"
//        }
//        isLoading = false
//    }
//}
//
//
//
//struct ContentView: View {
//    
//    @Environment(\.colorScheme) var colorScheme
//    @State private var selection: Tabkey = .student
//    
//    @StateObject private var viewModel = RoutineViewModel()    
//    
//    var body: some View {
//        TabView(selection: $selection) {
//            Tab ("Student", systemImage: "graduationcap", value: Tabkey.student) {
//                StudentView()
//            }
//            
//            Tab ("Teacher", systemImage: "person.crop.rectangle.stack", value: Tabkey.teacher) {
//                TeacherView()
//            }
//            
//            Tab ("EmptyRoom", systemImage: "square.stack", value: Tabkey.emptyRoom) {
//                Group {
//                    if viewModel.isLoading {
//                        ProgressView("Loading routines...")
//                            .progressViewStyle(CircularProgressViewStyle())
//                    } else if let errorMessage = viewModel.errorMessage {
//                        VStack {
//                            Text("Error")
//                                .font(.headline)
//                            Text(errorMessage)
//                                .font(.subheadline)
//                                .multilineTextAlignment(.center)
//                            Button("Retry") {
//                                Task {
//                                    await viewModel.fetchRoutines()
//                                }
//                            }
//                            .padding()
//                        }
//                    } else if viewModel.routines.isEmpty {
//                        Text("No routines available")
//                            .foregroundColor(.secondary)
//                    } else {
//                        List(viewModel.routines) { routine in
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text(routine.courseInfo?.title ?? "")
//                                    .font(.headline)
//                                Text(routine.teacherInfo?.name ?? "")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                                Text("\(routine.day ?? "") • \(routine.startTime ?? "")-\(routine.endTime ?? "")")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                                Text("Room: \(routine.room ?? "") • Section: \(routine.section ?? "")")
//                                    .font(.caption2)
//                                    .foregroundColor(.secondary)
//                            }
//                            .padding(.vertical, 2)
//                        }
//                    }
//                }
//            }
//            
//            if selection == .student || selection == .studentSearch {
//                Tab(value: Tabkey.studentSearch, role: .search) {
//                        
//                }
//            } else if selection == .teacher || selection == .teacherSearch {
//                Tab(value: Tabkey.teacherSearch, role: .search) {
//                }
//            }
//        }
//        .tabBarMinimizeBehavior(.onScrollDown)
//        .tint(Color(hue: 0.5, saturation: 0.8, brightness: colorScheme == .light ? 0.65 : 0.75))
//        .task {
//            await viewModel.fetchRoutines()
//        }
//    }
//}
//
//private enum Tabkey: Hashable {
//    case student
//    case teacher
//    case emptyRoom
//    case timepicker
//    case studentSearch
//    case teacherSearch
//}
//
//#Preview {
//    ContentView()
//}




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

