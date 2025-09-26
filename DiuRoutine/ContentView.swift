import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var selection: Tabkey = .student
    
    var body: some View {
        TabView(selection: $selection) {
            Tab ("Student", systemImage: "graduationcap", value: Tabkey.student) {
                StudentView()
            }
            
            Tab ("Teacher", systemImage: "person.crop.rectangle.stack", value: Tabkey.teacher) {
                TeacherView()
            }
            
            Tab ("EmptyRoom", systemImage: "square.stack", value: Tabkey.emptyRoom) {
                Text("Hello")
            }
            
            if selection == .student || selection == .studentSearch {
                Tab(value: Tabkey.studentSearch, role: .search) {
                        
                }
            } else if selection == .teacher || selection == .teacherSearch {
                Tab(value: Tabkey.teacherSearch, role: .search) {
                    
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Color(hue: 0.5, saturation: 0.8, brightness: colorScheme == .light ? 0.65 : 0.75))
    }
}

private enum Tabkey: Hashable {
    case student
    case teacher
    case emptyRoom
    case timepicker
    case studentSearch
    case teacherSearch
}

#Preview {
    ContentView()
}
