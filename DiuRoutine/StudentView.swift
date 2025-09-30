import SwiftUI
import SwiftData

struct StudentView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedSection: RoutineType = .routine
    @State private var searchText: String = ""
    @Query private var routines: [RoutineDO]
    
    @Binding var isSearchActive: Bool
    @State var insightSheet: Bool = false
    
    enum RoutineType: String, CaseIterable, Identifiable {
        case routine, insights
        var id: Self { self }
    }
    
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
        guard !searchText.isEmpty else { return false }
        return allSections.contains(where: { $0.caseInsensitiveCompare(searchText) == .orderedSame })
    }
    
    
    private var filteredRoutines: [RoutineDO] {
        guard !searchText.isEmpty else { return [] }
        guard isValidSection else { return [] }
        
        var filtered = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedStandardContains(searchText)
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
        
//            // Print filtered routines
//        print("=== Filtered Routines for \(searchText) on \(selectedDay) ===")
//        print("Total routines found: \(sorted.count)")
//        for (index, routine) in sorted.enumerated() {
//            print("\n[\(index + 1)]")
//            print("  Course: \(routine.courseInfo?.title ?? "N/A") - \(routine.courseInfo?.code ?? "N/A")")
//            print("  Section: \(routine.section ?? "N/A")")
//            print("  Time: \(routine.startTime ?? "N/A") - \(routine.endTime ?? "N/A")")
//            print("  Teacher: \(routine.teacherInfo?.name ?? "N/A") (\(routine.teacherInfo?.initial ?? routine.initial ?? "N/A"))")
//            print("  Room: \(routine.room ?? "N/A")")
//            print("  Day: \(routine.day ?? "N/A")")
//        }
//        print("=====================================\n")
        
        return sorted
    }
    
    private var uniqueCoursesForSection: [(title: String, code: String)] {
        guard !searchText.isEmpty else { return [] }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(searchText)
        }
        
        var seen = Set<String>()
        var uniqueCourses: [(title: String, code: String)] = []
        
        for routine in routinesForSection {
            let code = routine.courseInfo?.code ?? "N/A"
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
    }
    
    private let timeOrder = ["08:30", "10:00", "11:30", "01:00", "02:30", "04:00"]
    
    private var mergedRoutines: [MergedRoutine] {
        let routinesForDay = filteredRoutines
        
        let grouped = Dictionary(grouping: routinesForDay) { routine in
            RoutineGroupKey(
                teacherInitial: routine.teacherInfo?.initial ?? routine.initial ?? "N/A",
                courseCode: routine.courseInfo?.code ?? "N/A"
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
            let courseTitle = sortedGroup.first?.courseInfo?.title ?? "Unknown Course"
            let section     = sortedGroup.first?.section ?? "N/A"
            let room        = sortedGroup.first?.room ?? "N/A"
            
            let mergedRoutine = MergedRoutine(
                startTime: startTime,
                endTime: endTime,
                courseTitle: courseTitle,
                courseCode: key.courseCode,
                section: section,
                teacherInitial: key.teacherInitial,
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

    
    private var totalWeeklyDurationForSection: String {
        guard !searchText.isEmpty else { return "0h 0m" }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(searchText)
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
    
    func calculateDurationMinutes(from startTime: String, to endTime: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        
        func normalize(_ time: String) -> Int? {
            guard let date = formatter.date(from: time) else { return nil }
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            
            if hour < 8 {
                hour += 12
            }
            return hour * 60 + minute
        }
        
        guard let start = normalize(startTime),
              let end = normalize(endTime) else {
            return 0
        }
        
        return max(0, end - start)
    }
    
    private var uniqueTeachersForSection: [TeacherInfo] {
        guard !searchText.isEmpty else { return [] }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(searchText)
        }
        
        var seen = Set<String>()
        var teachers: [TeacherInfo] = []
        
        for routine in routinesForSection {
            let initial = routine.teacherInfo?.initial ?? routine.initial ?? "N/A"
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
        guard !searchText.isEmpty else { return 0 }
        
        let routinesForSection = routines.filter { routine in
            guard let section = routine.section else { return false }
            return section.localizedCaseInsensitiveContains(searchText)
        }
        
        let groupedByDay = Dictionary(grouping: routinesForSection) { routine in
            routine.day ?? "Unknown"
        }
        
        var totalClasses = 0
        for (_, routinesInDay) in groupedByDay {
            let mergedForDay = Dictionary(grouping: routinesInDay) { routine in
                RoutineGroupKey(
                    teacherInitial: routine.teacherInfo?.initial ?? routine.initial ?? "N/A",
                    courseCode: routine.courseInfo?.code ?? "N/A"
                )
            }
            totalClasses += mergedForDay.count
        }
        
        return totalClasses
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isValidSection {
                    CalendarHeaderView2(selectedDate: $selectedDate)
                }
                
                RoutinePageView(
                    selectedDate: selectedDate,
                    mergedRoutines: mergedRoutines,
                    hasSearchText: !searchText.isEmpty,
                    isValidSection: isValidSection
                )
            }
            .searchable(text: $searchText, isPresented: $isSearchActive, placement: .toolbar, prompt: "Search Section (61_N)")
            .searchSuggestions {
                ForEach(allSections.filter { section in
                    searchText.isEmpty || section.localizedCaseInsensitiveContains(searchText)
                }, id: \.self) { section in
                    HStack {
                        Text(section).searchCompletion(section)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        searchText = section
                        isSearchActive = false
                    }
                }
            }
            .sheet(isPresented: $insightSheet) {
                ScrollView(showsIndicators: false) {
                    StudentInsight(
                        totalCoursesEnrolled: uniqueCoursesForSection.count,
                        totalWeeklyClasses: totalWeeklyClasses,
                        totalWeeklyHours: totalWeeklyDurationForSection,
                        courses: uniqueCoursesForSection,
                        teachers: uniqueTeachersForSection
                    )
                }
                .padding()
                .presentationDetents([.medium])
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
                
                if isValidSection {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            insightSheet = true
                        }, label: {
                            Text(searchText).font(.caption.bold())
                        })
                    }
                }
                
                ToolbarItem(placement: .title) {
                    Text("Student").font(.title.bold())
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                            // Settings action
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchActive = false
        }
    }
}

struct MergedRoutine: Identifiable {
    let id = UUID()
    let startTime: String
    var endTime: String
    let courseTitle: String
    let courseCode: String
    let section: String
    let teacherInitial: String
    let room: String
    var routines: [RoutineDO]
    
    var duration: String {
        return calculateDuration(from: startTime, to: endTime)
    }
}

struct RoutinePageView: View {
    let selectedDate: Date?
    let mergedRoutines: [MergedRoutine]
    let hasSearchText: Bool
    let isValidSection: Bool
    
    @Namespace private var topID
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)
                    
                    contentView
                        .padding()
                }
                .padding(.bottom, 120)
            }
            .onChange(of: selectedDate) { _, _ in
                scrollToTop(proxy: proxy)
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if mergedRoutines.isEmpty {
            emptyStateView
        } else {
            routinesList
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: getEmptyStateIcon())
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            
            Text(getEmptyStateText())
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    private func getEmptyStateIcon() -> String {
        if !hasSearchText {
            return "calendar.badge.clock"
        } else if !isValidSection {
            return "exclamationmark.magnifyingglass"
        } else {
            return "magnifyingglass"
        }
    }
    
    private func getEmptyStateText() -> String {
        if !hasSearchText {
            return "Search by section to view classes"
        } else if !isValidSection {
            return "Invalid section. Please enter a valid section."
        } else {
            return "No class found"
        }
    }
    
    private var routinesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(mergedRoutines) { mergedRoutine in
                StudentCard(mergedRoutine: mergedRoutine)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    private func scrollToTop(proxy: ScrollViewProxy) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            proxy.scrollTo(topID, anchor: .top)
        }
    }
}

struct StudentCard: View {
    let mergedRoutine: MergedRoutine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("\(format12Hour(mergedRoutine.startTime)) - \(format12Hour(mergedRoutine.endTime))")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.2)
                
                Spacer()
                
                Text(mergedRoutine.duration)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            OverflowingText(text: "\(mergedRoutine.courseTitle) - \(mergedRoutine.courseCode)")
            
            HStack {
                HStack(alignment: .center, spacing: 10) {
                    Text("Section:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(mergedRoutine.section)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 20) {
                    Text("Teacher:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Button(action: {
                            // Teacher info action
                    }) {
                        Text(mergedRoutine.teacherInitial)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
            
            HStack(alignment: .center, spacing: 10) {
                Text("Room:")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(mergedRoutine.room)
                    .lineLimit(1)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
        .lineLimit(1)
        .padding()
        .background(.secondary.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct OverflowingText: View {
    let text: String
    @State private var isOverflowing = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding([.top, .bottom], 6)
                    .lineLimit(1)
                    .brightness(-0.2)
                    .background(
                        GeometryReader { textGeo in
                            Color.clear
                                .onAppear {
                                    if textGeo.size.width > geo.size.width {
                                        isOverflowing = true
                                    }
                                }
                        }
                    )
            }
            .disabled(!isOverflowing)
        }
        .frame(height: 36)
    }
}

func format12Hour(_ time: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm"
    guard let date = formatter.date(from: time) else { return time }
    
    let calendar = Calendar.current
    var comps = calendar.dateComponents([.hour, .minute], from: date)
    
    if let hour = comps.hour, hour < 8 {
        comps.hour = hour + 12
    }
    let adjustedDate = calendar.date(from: comps) ?? date
    
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: adjustedDate)
}

func calculateDuration(from startTime: String, to endTime: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm"
    
    func normalize(_ time: String) -> Int? {
        guard let date = formatter.date(from: time) else { return nil }
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        if hour < 8 {
            hour += 12
        }
        return hour * 60 + minute
    }
    
    guard let start = normalize(startTime),
          let end = normalize(endTime) else {
        return "N/A"
    }
    
    let duration = end - start
    guard duration > 0 else { return "N/A" }
    
    let hours = duration / 60
    let minutes = duration % 60
    
    if hours > 0 && minutes > 0 {
        return "\(hours)h \(minutes)m"
    } else if hours > 0 {
        return "\(hours)h"
    } else {
        return "\(minutes)m"
    }
}

#Preview("Student View") {
    NavigationView {
        StudentView(isSearchActive: .constant(false))
    }
}

struct TeacherInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let initial: String
    let imageUrl: String
    let designation: String
}

struct StudentInsight: View {
    let totalCoursesEnrolled: Int
    let totalWeeklyClasses: Int
    let totalWeeklyHours: String
    let courses: [(title: String, code: String)]
    let teachers: [TeacherInfo]
    
    init(
        totalCoursesEnrolled: Int = 0,
        totalWeeklyClasses: Int = 0,
        totalWeeklyHours: String = "0h 0m",
        courses: [(title: String, code: String)],
        teachers: [TeacherInfo]
    ) {
        self.totalCoursesEnrolled = totalCoursesEnrolled
        self.totalWeeklyClasses = totalWeeklyClasses
        self.totalWeeklyHours = totalWeeklyHours
        self.courses = courses
        self.teachers = teachers
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Section: ")
                            .font(.headline.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("61_N")
                            .font(.headline.bold())
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                    
                    HStack {
                        Text("Routine Version: ")
                            .font(.headline.bold())
                            .foregroundStyle(.secondary)
                        Text("2.0")
                            .font(.headline.bold())
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                }
                
                Spacer()
                
                ZStack(alignment: .center) {
                    Button(action: {
                            // Download PDF
                    }) {
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.teal.opacity(0.1))
                                .frame(height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: "arrow.down.app.fill")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.teal)
                                    .brightness(-0.1)
                                
                                Text("PDF")
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.teal)
                                    .fontWeight(.bold)
                                    .brightness(-0.1)
                            }
                        }
                    }
                }
                .frame(maxWidth: 70)
            }
            
            Divider()
                .frame(height: 1)
                .background(.gray.opacity(0.45))
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Teachers")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.1)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(teachers) { teacher in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: teacher.imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(teacher.name) - \(teacher.initial)")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(teacher.designation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Divider()
                .frame(height: 1)
                .background(.gray.opacity(0.45))
                .padding(.vertical)
            
            VStack(spacing: 8) {
                Text("Enrolled Course")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.1)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(courses, id: \.code) { course in
                    HStack(alignment: .center) {
                        Text(course.title)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(course.code)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                }
            }
            
            Divider()
                .frame(height: 1)
                .background(.gray.opacity(0.45))
                .padding(.vertical)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 16) {
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.clear)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Total Course Enrolled: \(totalCoursesEnrolled)")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.primary.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.clear)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Total Weekly Classes: \(totalWeeklyClasses)")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.primary.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.clear)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Weekly Class Hours: \(totalWeeklyHours)")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.primary.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
            }
            .padding(.bottom, 8)
        }
        .lineLimit(1)
        .padding(15)
    }
}
