import SwiftUI

struct WeekCalendarView: View {
    let isDragging: Bool
    
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date
    
    @State private var weeks: [Week]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(_ title: Binding<String>, selection: Binding<Date>, focused: Binding<Week>, isDragging: Bool) {
        _title = title
        _focused = focused
        _selection = selection
        self.isDragging = isDragging
        
        let theNearestSaturday = Calendar.nearestSaturday(from: focused.wrappedValue.days.first ?? .now)
        let currentWeek = Week(
            days: Calendar.currentWeek(from: theNearestSaturday),
            order: .current
        )
        
        let previousWeek: Week = if let firstDay = currentWeek.days.first {
            Week(
                days: Calendar.previousWeek(from: firstDay),
                order: .previous
            )
        } else { Week(days: [], order: .previous) }
        
        let nextWeek: Week = if let lastDay = currentWeek.days.last {
            Week(
                days: Calendar.nextWeek(from: lastDay),
                order: .next
            )
        } else { Week(days: [], order: .next) }
        
        _weeks = .init(initialValue: [previousWeek, currentWeek, nextWeek])
        _position = State(initialValue: ScrollPosition(id: focused.id))
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(weeks) { week in
                    VStack {
                        WeekView(week: week, selectedDate: $selection, dragProgress: .zero)
                            .frame(width: calendarWidth, height: Constants.dayHeight)
                            .onAppear { loadWeek(from: week) }
                    }
                }
            }
            .scrollTargetLayout()
            .frame(height: Constants.dayHeight)
        }
        .scrollDisabled(isDragging)
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            calendarWidth = newValue
        }
        .onChange(of: position) { _, newValue in
            guard let focusedWeek = weeks.first(where: { $0.id == (newValue.viewID as? String) }) else {
                return }
            focused = focusedWeek
            title = Calendar.monthAndYear(from: focusedWeek.days.last!)
        }
        .onChange(of: selection) { _, newValue in
                // newValue is already a non-optional Date, so no need for guard let
            guard let week = weeks.first(where: { $0.days.contains(newValue) }) else { return }
            focused = week
        }
    }
}

extension WeekCalendarView {
    func loadWeek(from week: Week) {
        if week.order == .previous, weeks.first == week, let firstDay = week.days.first {
            let previousWeek = Week(days: Calendar.previousWeek(from: firstDay), order: .previous)
            
            var weeks = self.weeks
            weeks.insert(previousWeek, at: 0)
            self.weeks = weeks
        } else if week.order == .next, weeks.last == week, let lastDay = week.days.last {
            let nextWeek = Week(days: Calendar.nextWeek(from: lastDay), order: .next)
            
            var weeks = self.weeks
            weeks.append(nextWeek)
            self.weeks = weeks
        }
    }
}
