import SwiftUI
import SwiftData

struct StudentView: View {
    @State private var selectedDate: Date = Date()
//    @State private var selectedDate: Date = Date()
    @State private var selectedSection: RoutineType = .routine
    
    enum RoutineType: String, CaseIterable, Identifiable {
        case routine, insights
        var id: Self { self }
    }
    
    @State private var searchText: String = ""
    @Query private var routines: [RoutineDO]
    
    
    private var allSections: [String] {
        let sections = routines.compactMap { $0.section }
        let mainSections = sections.compactMap { section -> String? in
                // Extract main section by removing digits at the end
            if let range = section.range(of: #"\d+$"#, options: .regularExpression) {
                return String(section[..<range.lowerBound])
            }
            return section
        }
        return Array(Set(mainSections)).sorted()
    }
    
        // Filtered routines based on search text and selected date
    private var filteredRoutines: [RoutineDO] {
        guard !searchText.isEmpty else { return [] }
        
            // Only allow if searchText matches an existing main section
        guard allSections.contains(where: { $0.caseInsensitiveCompare(searchText) == .orderedSame }) else {
            return []
        }
        
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
        
        
        return filtered.sorted { routine1, routine2 in
            guard let start1 = routine1.startTime, let start2 = routine2.startTime else {
                return false
            }
            return start1 < start2
        }
    }

    
        // MARK: - Grouping Key
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
            let sortedGroup = group.sorted { ($0.startTime ?? "") < ($1.startTime ?? "") }
            
            let startTime = sortedGroup.first?.startTime ?? "N/A"
            let endTime = sortedGroup.last?.endTime ?? "N/A"
            let courseTitle = sortedGroup.first?.courseInfo?.title ?? "Unknown Course"
            let section = sortedGroup.first?.section ?? "N/A"
            let room = sortedGroup.first?.room ?? "N/A"
            
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
        
            // Sort by predefined order
        return merged.sorted {
            guard let idx1 = timeOrder.firstIndex(of: $0.startTime),
                  let idx2 = timeOrder.firstIndex(of: $1.startTime) else {
                return $0.startTime < $1.startTime
            }
            return idx1 < idx2
        }
    }

    
    
    @State private var isSearchActive = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
//                CalendarHeaderView(selectedDate: $selectedDate)
                CalendarHeaderView2(selectedDate: $selectedDate)
        
                
                Picker("Section", selection: $selectedSection) {
                    Text("Routine").tag(RoutineType.routine)
                    Text("Insights").tag(RoutineType.insights)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                
                TabView(selection: $selectedSection) {
                    RoutinePageView(
                        selectedDate: selectedDate,
                        mergedRoutines: mergedRoutines,
                        hasSearchText: !searchText.isEmpty
                    )
                    .tag(RoutineType.routine)
                    
                    InsightsPageView(selectedDate: selectedDate)
                        .tag(RoutineType.insights)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.interactiveSpring, value: selectedSection)
            }
            .searchable(text: $searchText, isPresented: $isSearchActive, placement: .toolbarPrincipal, prompt: "Search by Section")
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("Student").font(.title.bold())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                            // Settings action
                    } label: {
                        Image(systemName: "gearshape.fill")
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

    // MARK: - Merged Routine Model
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

    // MARK: - Routine Page
struct RoutinePageView: View {
    let selectedDate: Date?
    let mergedRoutines: [MergedRoutine]
    let hasSearchText: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if mergedRoutines.isEmpty {
                    VStack {
                        Spacer()
                        Text(hasSearchText ? "No class found" : "Search by section to view classes")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.top, 50)
                        Spacer()
                    }
                } else {
                    ForEach(mergedRoutines) { mergedRoutine in
                        StudentCard(mergedRoutine: mergedRoutine)
                    }
                }
            }
            .padding()
        }
    }
}


//struct RoutinePageView: View {
//    let selectedDate: Date?
//    let mergedRoutines: [MergedRoutine]
//    let hasSearchText: Bool
//    
//    @Namespace private var topID   // anchor for scrolling
//    
//    var body: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                        // Hidden anchor at the very top
//                    Color.clear
//                        .frame(height: 0)
//                        .id(topID)
//                    
//                    if mergedRoutines.isEmpty {
//                        VStack {
//                            Spacer()
//                            Text(hasSearchText ? "No class found" : "Search by section to view classes")
//                                .font(.title2)
//                                .fontWeight(.medium)
//                                .foregroundStyle(.secondary)
//                                .padding(.top, 50)
//                            Spacer()
//                        }
//                    } else {
//                        ForEach(mergedRoutines) { mergedRoutine in
//                            StudentCard(mergedRoutine: mergedRoutine)
//                        }
//                    }
//                }
//                .padding()
//            }
//            .onChange(of: selectedDate) {
//                withAnimation(.easeInOut) {
//                    proxy.scrollTo(topID, anchor: .top)
//                }
//            }
//        }
//    }
//}

    // MARK: - Insights Page
struct InsightsPageView: View {
    let selectedDate: Date?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StudyInsightsCard()
            }
            .padding()
        }
    }
}

    // MARK: - Schedule Card
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

    // MARK: - Insights Cards
struct StudyInsightsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.teal)
                Text("Study Insights")
                    .font(.headline)
                Spacer()
            }
        }
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

    // MARK: - Helper Functions
func format12Hour(_ time: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm" // input like 08:30, 01:00
    guard let date = formatter.date(from: time) else { return time }
    
    let calendar = Calendar.current
    var comps = calendar.dateComponents([.hour, .minute], from: date)
    
        // Treat hours < 8 as PM
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
        
        if hour < 8 { // treat 01:00, 02:30, etc. as PM
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

    // MARK: - Preview
#Preview("Student View") {
    NavigationView {
        StudentView()
    }
}
