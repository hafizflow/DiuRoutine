import SwiftUI
import SwiftData

struct EmptyRoomView: View {
    @State private var selectedDate: Date = Date()
    @Binding var selectedTime: String?
    @Query private var routines: [RoutineDO]
    
    @Namespace private var topID
    @State private var animateContent = false
    @State private var showSettings = false
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    private let timeSlots = [
        "08:30 - 10:00",
        "10:00 - 11:30",
        "11:30 - 01:00",
        "01:00 - 02:30",
        "02:30 - 04:00",
        "04:00 - 05:30"
    ]
    
    private var dayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        return df
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return df
    }
    
    private func timeToMinutes(_ time: String) -> Int {
        let trimmed = time.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ":").map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2,
           let hourStr = parts.first, let minStr = parts.last,
           let hour = Int(hourStr),
           let min = Int(minStr) {
            var totalMinutes = hour * 60 + min
                // AM if hour 8–11; else PM (add 12 hours)
            if !(8...11).contains(hour) {
                totalMinutes += 12 * 60
            }
            return totalMinutes
        }
        return 0
    }
    
        /// Empty rooms for selected day **and selected time**
    private var emptyRoomsForDay: [RoutineDO] {
        let selectedDay = dayFormatter.string(from: selectedDate).uppercased()
        
        return routines.filter { routine in
                // Match day
            guard let routineDay = routine.day?.uppercased(),
                  routineDay == selectedDay else { return false }
            
                // Empty rooms = no section & no initial
            let hasNoSection = (routine.section?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            let hasNoInitial = (routine.initial?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            guard hasNoSection && hasNoInitial else { return false }
            
                // ✅ Filter by selected time slot using minutes for proper comparison
            if let activeTime = selectedTime {
                let parts = activeTime.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    let filterStart = String(parts[0])
                    let filterEnd = String(parts[1])
                    
                    let routineStartMin = timeToMinutes(routine.startTime ?? "")
                    let routineEndMin = timeToMinutes(routine.endTime ?? "")
                    let filterStartMin = timeToMinutes(filterStart)
                    let filterEndMin = timeToMinutes(filterEnd)
                    
                        // Check if routine fully overlaps within selected slot
                    return routineStartMin >= filterStartMin && routineEndMin <= filterEndMin
                }
            }
            return true // no filter → show all
        }
        .sorted { timeToMinutes($0.startTime ?? "") < timeToMinutes($1.startTime ?? "") }
    }
    
    @AppStorage("cStyle") private var cStyle: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                cStyle ?
                AnyView(CalendarHeaderView2(selectedDate: $selectedDate)) :
                AnyView(CalendarHeaderView1(selectedDate: $selectedDate)) 
                
                
                HStack(alignment: .center, spacing: 12) {
                    HStack(spacing: 6) {
                        Text("Empty:")
                            .font(.body.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("\(emptyRoomsForDay.count)")
                            .font(.body.bold())
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            selectedTime = nil
                        } label: {
                            Label("All Times", systemImage: selectedTime == nil ? "checkmark" : "")
                        }
                        
                        Divider()
                        
                        ForEach(timeSlots, id: \.self) { time in
                            Button {
                                selectedTime = time
                            } label: {
                                Label(time, systemImage: selectedTime == time ? "checkmark" : "")
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.subheadline)
                            Text(selectedTime ?? "All Times")
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
                .padding(.leading, 8)
                .padding(.bottom, 16)
                .background(Color(.systemBackground))
                
                    // Room Cards with Animation
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Color.clear.frame(height: 2).id(topID)
                            
                            contentView.padding(.horizontal)
                        }
                        .padding(.bottom, 150)
                    }
                    .onChange(of: selectedDate) { _, _ in
                            // Reset animation first
                        animateContent = false
                        scrollToTop(proxy: proxy)
                        
                            // Trigger animation after a brief delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                animateContent = true
                            }
                        }
                    }
                    .onChange(of: selectedTime) { _, _ in
                            // Reset animation when time changes
                        animateContent = false
                        scrollToTop(proxy: proxy)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                animateContent = true
                            }
                        }
                    }
                    .onChange(of: emptyRoomsForDay.count) { _, _ in
                            // Animate when room count changes
                        animateContent = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                animateContent = true
                            }
                        }
                    }
                }
            }
            .preferredColorScheme(userTheme.colorScheme)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(StudentRoutineStore())
                    .environmentObject(TeacherRoutineStore())
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "line.3.horizontal.decrease") {
                        showSettings = true
                    }
                        .tint(.primary)
                        .contentShape(Rectangle())
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Empty Rooms")
                        .font(.title.bold())
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                animateContent = true
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if emptyRoomsForDay.isEmpty {
            emptyStateView
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.9)
        } else {
            roomsList
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.9)
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: 90)
            ContentUnavailableView(
                "No Empty Rooms",
                systemImage: "door.left.hand.closed",
                description: Text("No Empty Room Found for Today.")
            )
            Spacer()
        }
    }
    
    private var roomsList: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(emptyRoomsForDay, id: \.id) { room in
                RoomCard(room: room)
            }
        }
    }
    
    private func scrollToTop(proxy: ScrollViewProxy) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            proxy.scrollTo(topID, anchor: .top)
        }
    }
}

    // Room Card Component
struct RoomCard: View {
    let room: RoutineDO
    @Environment(\.colorScheme) var colorScheme
    
    private var cleanRoomName: String {
        let roomName = room.room ?? "Unknown"
        return roomName.replacingOccurrences(of: "(COM LAB)", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack(spacing: 12) {
                // Room Info
            VStack(spacing: 6) {
                Text("\(cleanRoomName)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(format12Hour(room.startTime ?? "N/A"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("-")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(format12Hour(room.endTime ?? "N/A"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                    // Available Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Available")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(colorScheme == .light ?  Color.clear : Color.gray.opacity(0.15)))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1.5)
        )
    }
}
