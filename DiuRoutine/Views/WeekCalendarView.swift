import SwiftUI

struct WeekCalendarView: View {
    @Binding var title: String
    @Binding var selection: Date
    @Binding var focused: Week
    let isDragging: Bool
    
    init(_ title: Binding<String>, selection: Binding<Date>, focused: Binding<Week>, isDragging: Bool) {
        _title = title
        _selection = selection
        _focused = focused
        self.isDragging = isDragging
    }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            WeekCalendarViewIOS18(
                title: $title,
                selection: $selection,
                focused: $focused,
                isDragging: isDragging
            )
        } else {
            WeekCalendarViewLegacy(
                title: $title,
                selection: $selection,
                focused: $focused,
                isDragging: isDragging
            )
        }
    }
}

    // MARK: - iOS 18+ Implementation
@available(iOS 18.0, *)
struct WeekCalendarViewIOS18: View {
    let isDragging: Bool
    
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date
    
    @State private var weeks: [Week]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(title: Binding<String>, selection: Binding<Date>, focused: Binding<Week>, isDragging: Bool) {
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
            guard let week = weeks.first(where: { $0.days.contains(newValue) }) else { return }
            focused = week
        }
    }
    
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

    // MARK: - iOS 17 and Lower Implementation
struct WeekCalendarViewLegacy: View {
    let isDragging: Bool
    
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date
    
    @State private var weeks: [Week]
    @State private var currentWeekId: String
    @State private var calendarWidth: CGFloat = .zero
    @State private var scrollToId: String?
    
    init(title: Binding<String>, selection: Binding<Date>, focused: Binding<Week>, isDragging: Bool) {
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
        _currentWeekId = State(initialValue: focused.wrappedValue.id)
        _scrollToId = State(initialValue: focused.wrappedValue.id)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: .zero) {
                    ForEach(weeks) { week in
                        VStack {
                            WeekView(week: week, selectedDate: $selection, dragProgress: .zero)
                                .frame(width: calendarWidth, height: Constants.dayHeight)
                                .onAppear { loadWeek(from: week) }
                        }
                        .id(week.id)
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: WeekScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("weekScroll")).minX
                        )
                    }
                )
            }
            .coordinateSpace(name: "weekScroll")
            .scrollTargetLayout()
            .frame(height: Constants.dayHeight)
            .scrollDisabled(isDragging)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .onPreferenceChange(WeekScrollOffsetPreferenceKey.self) { offset in
                updateCurrentWeek(offset: offset)
            }
            .onChange(of: scrollToId) { _, newId in
                guard let newId = newId else { return }
                withAnimation {
                    proxy.scrollTo(newId, anchor: .center)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToId = nil
                }
            }
            .onAppear {
                proxy.scrollTo(currentWeekId, anchor: .center)
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    calendarWidth = geometry.size.width
                }
                .onChange(of: geometry.size.width) { _, newWidth in
                    calendarWidth = newWidth
                }
            }
        )
        .onChange(of: selection) { _, newValue in
            guard let week = weeks.first(where: { $0.days.contains(newValue) }) else { return }
            focused = week
            currentWeekId = week.id
            scrollToId = week.id
        }
    }
    
    private func updateCurrentWeek(offset: CGFloat) {
        guard calendarWidth > 0 else { return }
        
        let index = Int(round(-offset / calendarWidth))
        let safeIndex = max(0, min(index, weeks.count - 1))
        
        guard safeIndex < weeks.count else { return }
        
        let newWeek = weeks[safeIndex]
        
        if newWeek.id != currentWeekId {
            currentWeekId = newWeek.id
            focused = newWeek
            
            if let lastDay = newWeek.days.last {
                title = Calendar.monthAndYear(from: lastDay)
            }
        }
    }
    
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

    // MARK: - Preference Key for Legacy Implementation
struct WeekScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

    // MARK: - Preview
#Preview {
    WeekCalendarView(
        .constant(""),
        selection: .constant(.now),
        focused: .constant(.current),
        isDragging: false
    )
}
