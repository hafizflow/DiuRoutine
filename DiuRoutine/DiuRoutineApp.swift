import SwiftUI
import SwiftData

@main
struct DiuRoutineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [RoutineDO.self, CourseInfoDO.self, TeacherInfoDO.self])
                .environmentObject(StudentRoutineStore())
                .environmentObject(TeacherRoutineStore())
        }
    }
}


