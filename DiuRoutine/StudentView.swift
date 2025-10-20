import SwiftUI
import SwiftData
import Combine

class StudentRoutineStore: ObservableObject {
    @Published var studentRoutineSearchText: String {
        didSet {
            UserDefaults.standard.set(studentRoutineSearchText, forKey: "studentRoutineSearchText")
        }
    }
    init() {
        self.studentRoutineSearchText = UserDefaults.standard.string(forKey: "studentRoutineSearchText") ?? ""
    }
    
    func clearData() {
        studentRoutineSearchText = ""
        UserDefaults.standard.removeObject(forKey: "studentRoutineSearchText")
    }
}

struct StudentView: View {
    @State private var selectedDate: Date = Date()
    @StateObject private var routineStore = StudentRoutineStore()
    @Query private var routines: [RoutineDO]
    @Binding var isSearchActive: Bool
    @State var insightSheet: Bool = false
    @Namespace private var animation
    @State private var showSettings: Bool = false
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @AppStorage("cStyle") private var cStyle: Bool = true
    
    private var allSections: [String] {
        let sections = routines.compactMap { $0.section }
        let mainSections = sections.compactMap { section -> String? in
            if let range = section.range(of: #"\d+$"#, options: .regularExpression) {
                return String(section[..<range.lowerBound])
            }
            return section
        }
        return Array(Set(mainSections)).sorted()
    }
    
    private var isValidSection: Bool {
        guard !routineStore.studentRoutineSearchText.isEmpty else { return false }
        return allSections.contains(where: { $0.caseInsensitiveCompare(routineStore.studentRoutineSearchText) == .orderedSame })
    }
    
    private var filteredRoutines: [RoutineDO] {
        guard !routineStore.studentRoutineSearchText.isEmpty else { return [] }
        guard isValidSection else { return [] }
        
        var filtered = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedStandardContains(routineStore.studentRoutineSearchText)
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
        
            // Print filtered routines
            //                    print("=== Filtered Routines for \(routineStore.studentRoutineSearchText) on \(selectedDay) ===")
            //                    print("Total routines found: \(sorted.count)")
            //                    for (index, routine) in sorted.enumerated() {
            //                        print("\n[\(index + 1)]")
            //                        print("  Course: \(routine.courseInfo?.title ?? "N/A") - \(routine.courseInfo?.code ?? "N/A")")
            //                        print("  Section: \(routine.section ?? "N/A")")
            //                        print("  Time: \(routine.startTime ?? "N/A") - \(routine.endTime ?? "N/A")")
            //                        print("  Teacher: \(routine.teacherInfo?.name ?? "N/A") (\(routine.teacherInfo?.initial ?? routine.initial ?? "N/A"))")
            //                        print("  Room: \(routine.room ?? "N/A")")
            //                        print("  Day: \(routine.day ?? "N/A")")
            //                    }
            //                    print("=====================================\n")
        
        return sorted
    }
    
    private var uniqueCoursesForSection: [(title: String, code: String)] {
        guard !routineStore.studentRoutineSearchText.isEmpty else { return [] }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(routineStore.studentRoutineSearchText)
        }
        
        var seen = Set<String>()
        var uniqueCourses: [(title: String, code: String)] = []
        
        for routine in routinesForSection {
            let code = routine.code ?? "N/A"
            if !seen.contains(code) {
                seen.insert(code)
                let title = routine.courseInfo?.title ?? "Unknown Course"
                uniqueCourses.append((title: title, code: code))
            }
        }
        
        return uniqueCourses
    }
    
    private struct RoutineGroupKey: Hashable {
        let teacherInitial: String
        let courseCode: String
        let section: String
    }
    
    private let timeOrder = ["08:30", "10:00", "11:30", "01:00", "02:30", "04:00"]
    
    private var mergedRoutines: [MergedRoutine] {
        let routinesForDay = filteredRoutines
        
        let grouped = Dictionary(grouping: routinesForDay) { routine in
            RoutineGroupKey(
                teacherInitial: routine.initial ?? "N/A",
                courseCode: routine.code ?? "N/A",
                section: routine.section ?? "N/A"
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
            let teacherInitial = key.teacherInitial
            let section     = sortedGroup.first?.section ?? "N/A"
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
        guard !routineStore.studentRoutineSearchText.isEmpty else { return [] }
        guard isValidSection else { return [] }
        
            // Get ALL routines for this section (no day filter)
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedStandardContains(routineStore.studentRoutineSearchText)
        }
        
            // Group by day
        let groupedByDay = Dictionary(grouping: routinesForSection) { routine in
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
                    teacherInitial: routine.initial ?? "N/A",
                    courseCode: routine.code ?? "N/A",
                    section: routine.section ?? "N/A"
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
                let teacherInitial = key.teacherInitial
                let section     = sortedGroup.first?.section ?? "N/A"
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
    
    private var totalWeeklyDurationForSection: String {
        guard !routineStore.studentRoutineSearchText.isEmpty else { return "0h 0m" }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(routineStore.studentRoutineSearchText)
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
    
    private var uniqueTeachersForSection: [TeacherInfo] {
        guard !routineStore.studentRoutineSearchText.isEmpty else { return [] }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(routineStore.studentRoutineSearchText)
        }
        
        var seen = Set<String>()
        var teachers: [TeacherInfo] = []
        
        for routine in routinesForSection {
            let initial = routine.initial ?? "N/A"
            if !seen.contains(initial) {
                seen.insert(initial)
                let name = routine.teacherInfo?.name ?? "Unknown Teacher"
                let designation = routine.teacherInfo?.designation ?? "Lecturer"
                let imageUrl = routine.teacherInfo?.imageUrl ?? "https://via.placeholder.com/100"
                
                teachers.append(TeacherInfo(
                    name: name,
                    initial: initial,
                    imageUrl: imageUrl,
                    designation: designation
                ))
            }
        }
        
        return teachers
    }
    
    private var totalWeeklyClasses: Int {
        guard !routineStore.studentRoutineSearchText.isEmpty else { return 0 }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(routineStore.studentRoutineSearchText)
        }
        
        let groupedByDay = Dictionary(grouping: routinesForSection) { routine in
            routine.day ?? "Unknown"
        }
        
        var totalClasses = 0
        for (_, routinesInDay) in groupedByDay {
            let mergedForDay = Dictionary(grouping: routinesInDay) { routine in
                RoutineGroupKey(
                    teacherInitial: routine.initial ?? "N/A",
                    courseCode: routine.code ?? "N/A",
                    section: routine.section ?? "N/A"
                )
            }
            totalClasses += mergedForDay.count
        }
        
        return totalClasses
    }
    
    @State private var updateAppInfo: AppVersionManager.ReturnResult?
    
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isValidSection {
                    cStyle ?
                    AnyView(CalendarHeaderView2(selectedDate: $selectedDate))
                    : AnyView(CalendarHeaderView1(selectedDate: $selectedDate))
                }
                
                StudentClasses(
                    selectedDate: selectedDate,
                    mergedRoutines: mergedRoutines,
                    hasSearchText: !routineStore.studentRoutineSearchText.isEmpty,
                    isValidSection: isValidSection,
                )
            }
            .preferredColorScheme(userTheme.colorScheme)
            .searchable(text: $routineStore.studentRoutineSearchText, isPresented: $isSearchActive, placement: .toolbar, prompt: "Search Section (61_N)")
            .searchSuggestions {
                ForEach(allSections.filter { section in
                    routineStore.studentRoutineSearchText.isEmpty || section.localizedCaseInsensitiveContains(routineStore.studentRoutineSearchText)
                }, id: \.self) { section in
                    HStack {
                        Text(section).searchCompletion(section).foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.left")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        routineStore.studentRoutineSearchText = section
                        isSearchActive = false
                    }
                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $insightSheet) {
                StudentInsight(
                    searchedSection: routineStore.studentRoutineSearchText,
                    totalCoursesEnrolled: uniqueCoursesForSection.count,
                    totalWeeklyClasses: totalWeeklyClasses,
                    totalWeeklyHours: totalWeeklyDurationForSection,
                    courses: uniqueCoursesForSection,
                    teachers: uniqueTeachersForSection,
                    mergedRoutines: weeklyMergedRoutines
                )
                
                .navigationTransition(.zoom(sourceID: "Insights", in: animation))
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isValidSection {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                insightSheet = true
                            }, label: {
                                Text(routineStore.studentRoutineSearchText).font(.callout.bold())
                            })
                            .contentShape(Rectangle())
                        }
                        .matchedTransitionSource(id: "Insights", in: animation)
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                insightSheet = true
                            }, label: {
                                Text(routineStore.studentRoutineSearchText).font(.callout.bold())
                            })
                            .contentShape(Rectangle())
                        }
                    }
                }
                
                ToolbarItem(placement: .title) {
                    Text("Student").font(.title.bold())
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "line.3.horizontal.decrease") {
                        showSettings = true
                    }.tint(.primary).contentShape(Rectangle())
                }
            }
        }
    }
}

#Preview("Student View") {
    NavigationView {
        StudentView(isSearchActive: .constant(false))
    }
}

