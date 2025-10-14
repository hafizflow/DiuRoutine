import SwiftUI
import SwiftData
import Toast
import Combine


class TeacherRoutineStore: ObservableObject {
    @Published var teacherRoutineSearchText: String {
        didSet {
            UserDefaults.standard.set(teacherRoutineSearchText, forKey: "teacherRoutineSearchText")
        }
    }
    init() {
        self.teacherRoutineSearchText = UserDefaults.standard.string(forKey: "teacherRoutineSearchText") ?? ""
    }
    
    func clearData() {
        teacherRoutineSearchText = ""
        UserDefaults.standard.removeObject(forKey: "teacherRoutineSearchText")
    }
}


struct TeacherView: View {
    @State private var selectedDate: Date = Date()
    @StateObject private var searchText = TeacherRoutineStore()
    @State private var insightSheet: Bool = false
    @State private var showSettings: Bool = false
    @Binding var isSearchActive: Bool
    @Namespace private var animation
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    @Query private var routines: [RoutineDO]
    
    private var allTeachers: [(name: String, initial: String)] {
        var seenInitials = Set<String>()
        var teachers: [(name: String, initial: String)] = []
        
        for routine in routines {
            let initial = routine.initial ?? "N/A"
            
                // Only add if we haven't seen this initial before
            if !seenInitials.contains(initial) {
                seenInitials.insert(initial)
                let name = routine.teacherInfo?.name ?? "Unknown"
                teachers.append((name, initial))
            }
        }
        return teachers.sorted { $0.name < $1.name }
    }
    
    private var isValidTeacher: Bool {
        guard !searchText.teacherRoutineSearchText.isEmpty else { return false }
        return allTeachers.contains { teacher in
            teacher.name.caseInsensitiveCompare(searchText.teacherRoutineSearchText) == .orderedSame ||
            teacher.initial.caseInsensitiveCompare(searchText.teacherRoutineSearchText) == .orderedSame
        }
    }
    
    private var filteredRoutines: [RoutineDO] {
        guard !searchText.teacherRoutineSearchText.isEmpty else { return [] }
        guard isValidTeacher else { return [] }
        
//        var filtered = routines.filter { routine in
//            guard let initial = routine.initial else { return false }
//            return initial.localizedStandardContains(searchText.teacherRoutineSearchText)
//        }
        
        var filtered = routines.filter { routine in
            guard let initial = routine.initial else { return false }
            return initial.caseInsensitiveCompare(searchText.teacherRoutineSearchText) == .orderedSame
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let selectedDay = dayFormatter.string(from: selectedDate)
        
        filtered = filtered.filter { routine in
            guard let routineDay = routine.day else { return false }
            return routineDay.localizedCaseInsensitiveContains(selectedDay)
        }
        
        let sorted = filtered.sorted { routine1, routine2 in
            guard let start1 = routine1.startTime, let start2 = routine2.startTime else {
                return false
            }
            return start1 < start2
        }
        
//             Print filtered routines
//        print("=== Filtered Routines for \(searchText) on \(selectedDay) ===")
//        print("Total routines found: \(sorted.count)")
//        for (index, routine) in sorted.enumerated() {
//            print("\n[\(index + 1)]")
//            print("  Course: \(routine.courseInfo?.title ?? "N/A") - \(routine.courseInfo?.code ?? "N/A")")
//            print("  Section: \(routine.section ?? "N/A")")
//            print("  Time: \(routine.startTime ?? "N/A") - \(routine.endTime ?? "N/A")")
//            print("  Teacher: \(routine.teacherInfo?.name ?? "N/A") (\(routine.initial ?? "N/A"))")
//            print("  Room: \(routine.room ?? "N/A")")
//            print("  Day: \(routine.day ?? "N/A")")
//        }
//        print("=====================================\n")
        
        return sorted
    }
    
    private struct RoutineGroupKey: Hashable {
        let section: String
        let courseCode: String
    }
    
    private let timeOrder = ["08:30", "10:00", "11:30", "01:00", "02:30", "04:00"]
    
    private var mergedRoutines: [MergedRoutine] {
        let routinesForDay = filteredRoutines
        
        let grouped = Dictionary(grouping: routinesForDay) { routine in
            RoutineGroupKey(
                section: routine.section ?? "N/A",
                courseCode: routine.code ?? "N/A"
            )
        }
        
        var merged: [MergedRoutine] = []
        
        for (key, group) in grouped {
            let sortedGroup = group.sorted { lhs, rhs in
                guard
                    let idx1 = timeOrder.firstIndex(of: lhs.startTime ?? ""),
                    let idx2 = timeOrder.firstIndex(of: rhs.startTime ?? "")
                else {
                    return (lhs.startTime ?? "") < (rhs.startTime ?? "")
                }
                return idx1 < idx2
            }
            
            let startTime = sortedGroup.first?.startTime ?? "N/A"
            let endTime   = sortedGroup.last?.endTime ?? "N/A"
            let courseTitle = sortedGroup.first?.courseInfo?.title ?? "Unknown"
            let courseCode = key.courseCode
            let teacherInitial = sortedGroup.first?.initial ?? "N/A"
            let section     = key.section
            let room        = sortedGroup.first?.room ?? "N/A"
            let teacherName        = sortedGroup.first?.teacherInfo?.name ?? "Unknown"
            let teacherDesignation = sortedGroup.first?.teacherInfo?.designation ?? "Unknown"
            let teacherEmail       = sortedGroup.first?.teacherInfo?.email ?? "N/A"
            let teacherCell        = sortedGroup.first?.teacherInfo?.cell ?? "N/A"
            let teacherRoom        = sortedGroup.first?.teacherInfo?.teacherRoom ?? "N/A"
            let techerImageUrl     = sortedGroup.first?.teacherInfo?.imageUrl ?? ""
            
            let mergedRoutine = MergedRoutine(
                startTime: startTime,
                endTime: endTime,
                courseTitle: courseTitle,
                courseCode: courseCode,
                section: section,
                teacherInitial: teacherInitial,
                teacherName: teacherName,
                teacherDesignation: teacherDesignation,
                teacherRoom: teacherRoom,
                teacherCell: teacherCell,
                teacherEmail: teacherEmail,
                teacherImageUrl: techerImageUrl,
                room: room,
                routines: sortedGroup
            )
            
            merged.append(mergedRoutine)
        }
        
        return merged.sorted {
            guard let idx1 = timeOrder.firstIndex(of: $0.startTime),
                  let idx2 = timeOrder.firstIndex(of: $1.startTime) else {
                return $0.startTime < $1.startTime
            }
            return idx1 < idx2
        }
    }
    
        // NEW: Get all routines for the entire week (for PDF)
    private var weeklyMergedRoutines: [MergedRoutine] {
        guard !searchText.teacherRoutineSearchText.isEmpty else { return [] }
        guard isValidTeacher else { return [] }
        
            // Get ALL routines for this teacher (no day filter)
        let routinesForTeacher = routines.filter { routine in
            guard let initial = routine.initial else { return false }
            return initial.localizedStandardContains(searchText.teacherRoutineSearchText)
        }
        
            // Group by day
        let groupedByDay = Dictionary(grouping: routinesForTeacher) { routine in
            routine.day ?? "Unknown"
        }
        
        var allMerged: [MergedRoutine] = []
        
        for (_, dayRoutines) in groupedByDay {
            let sortedDayRoutines = dayRoutines.sorted { routine1, routine2 in
                guard let start1 = routine1.startTime, let start2 = routine2.startTime else {
                    return false
                }
                return start1 < start2
            }
            
            let dayGrouped = Dictionary(grouping: sortedDayRoutines) { routine in
                RoutineGroupKey(
                    section: routine.section ?? "N/A",
                    courseCode: routine.code ?? "N/A"
                )
            }
            
            var dayMerged: [MergedRoutine] = []
            
            for (key, group) in dayGrouped {
                let sortedGroup = group.sorted { lhs, rhs in
                    guard
                        let idx1 = timeOrder.firstIndex(of: lhs.startTime ?? ""),
                        let idx2 = timeOrder.firstIndex(of: rhs.startTime ?? "")
                    else {
                        return (lhs.startTime ?? "") < (rhs.startTime ?? "")
                    }
                    return idx1 < idx2
                }
                
                let startTime = sortedGroup.first?.startTime ?? "N/A"
                let endTime   = sortedGroup.last?.endTime ?? "N/A"
                let courseTitle = sortedGroup.first?.courseInfo?.title ?? "Unknown"
                let courseCode = key.courseCode
                let teacherInitial = sortedGroup.first?.initial ?? "N/A"
                let section     = key.section
                    // Remove "(COM LAB)" from room number
                let rawRoom = sortedGroup.first?.room ?? "N/A"
                let room = rawRoom.replacingOccurrences(of: "(COM LAB)", with: "").trimmingCharacters(in: .whitespaces)
                let teacherName        = sortedGroup.first?.teacherInfo?.name ?? "Unknown"
                let teacherDesignation = sortedGroup.first?.teacherInfo?.designation ?? "Unknown"
                let teacherEmail       = sortedGroup.first?.teacherInfo?.email ?? "N/A"
                let teacherCell        = sortedGroup.first?.teacherInfo?.cell ?? "N/A"
                let teacherRoom        = sortedGroup.first?.teacherInfo?.teacherRoom ?? "N/A"
                let teacherImageUrl    = sortedGroup.first?.teacherInfo?.imageUrl ?? ""
                
                let mergedRoutine = MergedRoutine(
                    startTime: startTime,
                    endTime: endTime,
                    courseTitle: courseTitle,
                    courseCode: courseCode,
                    section: section,
                    teacherInitial: teacherInitial,
                    teacherName: teacherName,
                    teacherDesignation: teacherDesignation,
                    teacherRoom: teacherRoom,
                    teacherCell: teacherCell,
                    teacherEmail: teacherEmail,
                    teacherImageUrl: teacherImageUrl,
                    room: room,
                    routines: sortedGroup
                )
                
                dayMerged.append(mergedRoutine)
            }
            
            allMerged.append(contentsOf: dayMerged)
        }
        
            // Define desired day order
        let dayOrder = ["SATURDAY", "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY"]
        
            // Sort merged routines by day order first, then by startTime
        return allMerged.sorted { a, b in
            let dayIndexA = dayOrder.firstIndex(of: a.routines.first?.day ?? "") ?? Int.max
            let dayIndexB = dayOrder.firstIndex(of: b.routines.first?.day ?? "") ?? Int.max
            
            if dayIndexA != dayIndexB {
                return dayIndexA < dayIndexB
            } else {
                guard let idxA = timeOrder.firstIndex(of: a.startTime),
                      let idxB = timeOrder.firstIndex(of: b.startTime) else {
                    return a.startTime < b.startTime
                }
                return idxA < idxB
            }
        }
    }
    
    private var uniqueCoursesForTeacher: [(title: String, code: String)] {
        guard !searchText.teacherRoutineSearchText.isEmpty else { return [] }
        
        let routinesForTeacher = routines.filter { routine in
            guard let initial = routine.initial else { return false }
            return initial.localizedCaseInsensitiveContains(searchText.teacherRoutineSearchText)
        }
        
        var seen = Set<String>()
        var uniqueCourses: [(title: String, code: String)] = []
        
        for routine in routinesForTeacher {
            let code = routine.code ?? "N/A"
            if !seen.contains(code) {
                seen.insert(code)
                let title = routine.courseInfo?.title ?? "Unknown Course"
                uniqueCourses.append((title: title, code: code))
            }
        }
        
        return uniqueCourses
    }
    
    private var totalWeeklyDurationForTeacher: String {
        guard !searchText.teacherRoutineSearchText.isEmpty else { return "0h 0m" }
        
        let routinesForSection = routines.filter { routine in
            guard let initial = routine.initial else { return false }
            return initial.localizedCaseInsensitiveContains(searchText.teacherRoutineSearchText)
        }
        
        let totalMinutes = routinesForSection.reduce(0) { partial, routine in
            guard let s = routine.startTime, let e = routine.endTime else { return partial }
            return partial + calculateDurationMinutes(from: s, to: e)
        }
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var totalWeeklyClasses: Int {
        guard !searchText.teacherRoutineSearchText.isEmpty else { return 0 }
        
        
        let routinesForTeacher = routines.filter { routine in
            guard let initial = routine.initial else { return false }
            return initial.localizedCaseInsensitiveContains(searchText.teacherRoutineSearchText)
        }
        
        let groupedByDay = Dictionary(grouping: routinesForTeacher) { routine in
            routine.day ?? "Unknown"
        }
        
        var totalClasses = 0
        for (_, routinesInDay) in groupedByDay {
            let mergedForDay = Dictionary(grouping: routinesInDay) { routine in
                RoutineGroupKey(
                    section: routine.section ?? "N/A",
                    courseCode: routine.code ?? "N/A"
                )
            }
            totalClasses += mergedForDay.count
        }
        
        return totalClasses
    }
    
    private var uniqueSectionsForTeacher: [String] {
        guard !searchText.teacherRoutineSearchText.isEmpty else { return [] }
        
        let routinesForTeacher = routines.filter { routine in
            guard let initial = routine.initial else { return false }
            return initial.localizedCaseInsensitiveContains(searchText.teacherRoutineSearchText)
        }
        
        var seen = Set<String>()
        var sections: [String] = []
        
        for routine in routinesForTeacher {
            let section = routine.section ?? "N/A"
            if !seen.contains(section) {
                seen.insert(section)
                sections.append(section)
            }
        }
        
            // Extract main sections (e.g., "61_N" from "61_N1", "61_N2")
        var mainSections = Set<String>()
        
        for section in sections {
                // Check if section ends with a digit (e.g., "61_N1", "61_N2")
            if let lastChar = section.last, lastChar.isNumber {
                    // Remove the last digit to get main section
                let mainSection = String(section.dropLast())
                mainSections.insert(mainSection)
            } else {
                    // It's already a main section
                mainSections.insert(section)
            }
        }
        
            // Filter: only include main sections that actually exist in the original list
            // OR include subsections if their main section doesn't exist
        var result: [String] = []
        
        for mainSection in mainSections {
            if sections.contains(mainSection) {
                    // Main section exists, add it
                result.append(mainSection)
            } else {
                    // Main section doesn't exist, add all subsections for this main
                let subsections = sections.filter { $0.hasPrefix(mainSection) && $0 != mainSection }
                result.append(contentsOf: subsections)
            }
        }
        
        return result.sorted()
    }

    private var teacherInfo: TeacherData {
        guard !searchText.teacherRoutineSearchText.isEmpty, isValidTeacher else {
            return TeacherData(
                name: "Unknown",
                initial: "N/A",
                designation: "N/A",
                phone: "N/A",
                email: "N/A",
                room: "N/A",
                imageUrl: ""
            )
        }
        
            // Find routine
        if let firstRoutine = routines.first(where: { routine in
            guard let initial = routine.teacherInfo?.initial else { return false }
            return initial.localizedCaseInsensitiveContains(searchText.teacherRoutineSearchText)
        }) {
            return TeacherData(
                name: firstRoutine.teacherInfo?.name ?? "Unknown",
                initial: firstRoutine.initial ?? "N/A",
                designation: firstRoutine.teacherInfo?.designation ?? "N/A",
                phone: firstRoutine.teacherInfo?.cell ?? "N/A",
                email: firstRoutine.teacherInfo?.email ?? "N/A",
                room: firstRoutine.teacherInfo?.teacherRoom ?? "N/A",
                imageUrl: firstRoutine.teacherInfo?.imageUrl ?? ""
            )
        }
        
            // Fallback
        return TeacherData(
            name: "Unknown",
            initial: "N/A",
            designation: "N/A",
            phone: "N/A",
            email: "N/A",
            room: "N/A",
            imageUrl: ""
        )
    }

    @AppStorage("cStyle") private var cStyle: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isValidTeacher {
                    cStyle ?
                    AnyView(CalendarHeaderView2(selectedDate: $selectedDate))
                    : AnyView(CalendarHeaderView1(selectedDate: $selectedDate))
                }
                
                TeacherClasses(
                    selectedDate: selectedDate,
                    mergedRoutines: mergedRoutines,
                    hasSearchText: !searchText.teacherRoutineSearchText.isEmpty,
                    isValidTeacher: isValidTeacher
                )
            }
            .preferredColorScheme(userTheme.colorScheme)
            .searchable(text: $searchText.teacherRoutineSearchText, isPresented: $isSearchActive, placement: .toolbar, prompt: "Search Teacher (Name/Initial)")
            .searchSuggestions {
                ForEach(allTeachers.filter { teacher in
                    searchText.teacherRoutineSearchText.isEmpty ||
                    teacher.name.localizedCaseInsensitiveContains(searchText.teacherRoutineSearchText) ||
                    teacher.initial.localizedCaseInsensitiveContains(searchText.teacherRoutineSearchText)
                }, id: \.initial) { teacher in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(teacher.name)
                                .foregroundStyle(.primary)
                            Text(teacher.initial)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.left")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        searchText.teacherRoutineSearchText = teacher.initial
                        isSearchActive = false
                    }
                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(StudentRoutineStore())
                    .environmentObject(TeacherRoutineStore())
            }
            .sheet(isPresented: $insightSheet) {
                    TeacherInsights(
                        searchedTeacher: searchText.teacherRoutineSearchText,
                        sections: uniqueSectionsForTeacher,
                        totalCoursesEnrolled: uniqueCoursesForTeacher.count,
                        totalWeeklyClasses: totalWeeklyClasses,
                        totalWeeklyHours: totalWeeklyDurationForTeacher,
                        courses: uniqueCoursesForTeacher,
                        teacher: teacherInfo,
                        mergedRoutines: weeklyMergedRoutines
                    )
                    .navigationTransition(.zoom(sourceID: "Insights", in: animation))
                    .presentationDetents([.fraction(0.6)])
                    .presentationDragIndicator(.visible)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if isSearchActive {
                        Button(action: {
                            isSearchActive = false
                        }, label: {
                            Text("Done")
                        })
                    }
                }
                
                if isValidTeacher {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                insightSheet = true
                            }, label: {
                                Text(searchText.teacherRoutineSearchText).font(.callout.bold())
                            })
                            .contentShape(Rectangle())
                        }
                        .matchedTransitionSource(id: "Insights", in: animation)
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                insightSheet = true
                            }, label: {
                                Text(searchText.teacherRoutineSearchText).font(.callout.bold())
                            })
                            .contentShape(Rectangle())
                        }
                    }
                }
                
                ToolbarItem(placement: .title) {
                    Text("Teacher").font(.title.bold())
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "line.3.horizontal.decrease") {
                        showSettings = true
                    }
                    .tint(.primary)
                    .contentShape(Rectangle())
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchActive = false
        }
    }
}

#Preview {
    TeacherView(isSearchActive: .constant(false))
}
