import SwiftUI

struct CalendarHeaderView2: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        WeekView2(selectedDate: $selectedDate)
            .padding(.bottom, 24)
            .padding(.top, 6)
    }
}

struct WeekView2: View {
    @Binding var selectedDate: Date
    @State private var showDatePicker = false
    @State private var weekOffset = 0
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
    
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 7
        return cal
    }
    
    private let weekCount = 301
    private let centerIndex = 150
    
    private var currentWeekStart: Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
    
    private func getDateForWeek(_ offset: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart)!
    }
    
    private func isDateInDisplayedWeek(_ date: Date, for offset: Int) -> Bool {
        let displayedWeek = getDateForWeek(offset)
        return calendar.isDate(date, equalTo: displayedWeek, toGranularity: .weekOfYear)
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        if isDateInDisplayedWeek(selectedDate, for: weekOffset) {
            return formatter.string(from: selectedDate)
        }
        
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                
                    // Show DatePicker Button
                Button(action: {
                    impactFeedback.impactOccurred()
                    showDatePicker = true
                }) {
                    HStack(spacing: 0) {
                        Text("\(monthYearString(for: getDateForWeek(weekOffset)))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "calendar.badge.checkmark")
                            .frame(width: 40, height: 40)
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                
                    // Today Button
                Button {
                    impactFeedback.impactOccurred()
                    withAnimation {
                        weekOffset = 0
                        selectedDate = Date()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text("Today")
                            .font(.subheadline)
                    }
                    .padding(8)
                    .background(
                        ZStack {
                            Color.clear
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        }
                    )
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
                .opacity(isDateInDisplayedWeek(Date(), for: weekOffset) ? 0 : 1)
                .offset(y: isDateInDisplayedWeek(Date(), for: weekOffset) ? 20 : 0)
                .scaleEffect(isDateInDisplayedWeek(Date(), for: weekOffset) ? 0.9 : 1)
                .animation(.easeInOut(duration: 0.3), value: isDateInDisplayedWeek(Date(), for: weekOffset))
                
            }
            .sheet(isPresented: $showDatePicker) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .onChange(of: selectedDate) { _, _ in
                    impactFeedback.impactOccurred()
                    showDatePicker = false
                }
                .padding(.horizontal)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
            }
            .padding(.leading, 6)
            
            
            
            
            TabView(selection: $weekOffset) {
                ForEach(-centerIndex..<centerIndex, id: \.self) { offset in
                    VStack {
                        WeekRowView(
                            baseDate: getDateForWeek(offset),
                            selectedDate: $selectedDate,
                            impactFeedback: impactFeedback
                        )
                        .padding(.horizontal, 4)
                    }
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 70)
            
        }
        .padding(.horizontal)
        .onChange(of: selectedDate) { _, newDate in
            let startOfNewDateWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: newDate))!
            
            if startOfNewDateWeek != getDateForWeek(weekOffset) {
                let newOffset = calendar.dateComponents([.weekOfYear], from: currentWeekStart, to: startOfNewDateWeek).weekOfYear ?? 0
                
                withAnimation {
                    weekOffset = newOffset
                }
            }
        }
        .onAppear {
            impactFeedback.prepare()
        }
    }
}

struct WeekRowView: View {
    let baseDate: Date
    @Binding var selectedDate: Date
    let impactFeedback: UIImpactFeedbackGenerator
    
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 7
        return cal
    }
    
    private var datesForWeek: [Date] {
        (0..<7).compactMap { index in
            let date = calendar.date(byAdding: .day, value: index, to: baseDate)
            if let date, calendar.component(.weekday, from: date) != 6 { 
                return date
            }
            return nil
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(datesForWeek, id: \.timeIntervalSince1970) { date in
                Button {
                    impactFeedback.impactOccurred()
                    selectedDate = date
                } label: {
                    DayView2(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

}

struct DayView2: View {
    let date: Date
    let isSelected: Bool
    
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 7
        return cal
    }
    
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.calendar = calendar
        return formatter.string(from: date).uppercased()
    }
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.calendar = calendar
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var textColor: Color {
        if isSelected {
            return .primary
        }
        if isToday {
            return .teal
        }
        return .primary
    }
    
    private var borderColor: Color {
        if isSelected {
            return .teal
        }
        return isToday ? .teal : .gray
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(weekdayString)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
            
            Text(dayString)
                .font(.title3)
                .fontWeight(isSelected ? .bold : .semibold)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(textColor)
        .padding(.vertical, 8)
        .background(
            ZStack {
                Color(isSelected ? Color.teal.opacity(0.3) : .clear)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: isToday ? 2 : 1.2)
            }
        )
        .cornerRadius(10)
    }
}

#Preview("Light Mode") {
    CalendarHeaderView2(selectedDate: .constant(.now))
}
