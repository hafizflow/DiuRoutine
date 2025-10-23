import SwiftUI

struct MonthCalendarView: View {
    @Binding var title: String
    @Binding var selection: Date
    @Binding var focused: Week
    let isDragging: Bool
    let dragProgress: CGFloat
    
    init(_ title: Binding<String>, selection: Binding<Date>, focused: Binding<Week>, isDragging: Bool,
         dragProgress: CGFloat) {
        _title = title
        _selection = selection
        _focused = focused
        self.isDragging = isDragging
        self.dragProgress = dragProgress
    }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            MonthCalendarViewIOS18(
                isDragging: isDragging,
                dragProgress: dragProgress,
                title: $title,
                focused: $focused,
                selection: $selection
            )
        } else {
            MonthCalendarViewLegacy(
                isDragging: isDragging,
                dragProgress: dragProgress,
                title: $title,
                focused: $focused,
                selection: $selection
            )
        }
    }
}

    // MARK: - iOS 18+ Implementation
@available(iOS 18.0, *)
struct MonthCalendarViewIOS18: View {
    @Binding var title: String
    @Binding var selection: Date
    @Binding var focused: Week
    let isDragging: Bool
    let dragProgress: CGFloat
    
    @State private var months: [Month]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(isDragging: Bool, dragProgress: CGFloat, title: Binding<String>, focused: Binding<Week>,
         selection: Binding<Date>) {
        self.isDragging = isDragging
        self.dragProgress = dragProgress
        _title = title
        _focused = focused
        _selection = selection
        
        let creationDate = focused.wrappedValue.days.last
        var currentMonth = Month(from: creationDate ?? .now, order: .current)
        
        let selection = selection.wrappedValue
        
        if let lastDayOfTheMonth = currentMonth.weeks.first?.days.last,
           !Calendar.isSameMonth(lastDayOfTheMonth, selection),
           let previousMonth = currentMonth.previousMonth
        {
        if focused.wrappedValue.days.contains(selection) {
            currentMonth = previousMonth
        }
        }
        
        _months = State(
            initialValue: [
                currentMonth.previousMonth,
                currentMonth,
                currentMonth.nextMonth
            ].compactMap(\.self)
        )
        _position = State(initialValue: ScrollPosition(id: currentMonth.id))
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(months) { month in
                    VStack {
                        MonthView(month: month, dragProgress: dragProgress, focused: $focused, selectedDate: $selection)
                            .offset(y: (1 - dragProgress) * verticalOffset(for: month))
                            .frame(width: calendarWidth, height: Constants.monthHeight)
                            .onAppear { loadMonth(from: month) }
                    }
                }
            }
        }
        .scrollTargetLayout()
        .frame(height: Constants.monthHeight)
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
            guard let focusedMonth = months.first(where: { $0.id == (newValue.viewID as? String) }),
                  let focusedWeek = focusedMonth.weeks.first
            else { return }
            
            if focusedMonth.weeks.flatMap(\.days).contains(selection),
               let selectedWeek = focusedMonth.weeks.first(where: { $0.days.contains(selection) })
            {
            focused = selectedWeek
            } else {
                focused = focusedWeek
            }
            
            title = Calendar.monthAndYear(from: focusedWeek.days.last!)
        }
        .onChange(of: selection) { _, newValue in
            let week = months.flatMap(\.weeks).first(where: { (week) -> Bool in
                week.days.contains(newValue)
            })
            
            if let week {
                focused = week
            }
        }
        .onChange(of: dragProgress) { _, newValue in
            guard newValue == 1 else { return }
            
            if let currentMonth = months.first(where: { $0.id == (position.viewID as? String) }),
               currentMonth.weeks.flatMap(\.days).contains(selection),
               let newFocus = currentMonth.weeks.first(where: { $0.days.contains(selection) })
            {
            focused = newFocus
            }
        }
    }
    
    func loadMonth(from month: Month) {
        if month.order == .previous, months.first == month, let previousMonth = month.previousMonth {
            var months = self.months
            months.insert(previousMonth, at: 0)
            self.months = months
        } else if month.order == .next, months.last == month, let nextMonth = month.nextMonth {
            var months = months
            months.append(nextMonth)
            self.months = months
        }
    }
    
    func verticalOffset(for month: Month) -> CGFloat {
        guard let index = month.weeks.firstIndex(where: { $0 == focused }) else { return .zero }
        let height = Constants.monthHeight / CGFloat(month.weeks.count)
        return CGFloat(month.weeks.count - 1) / 2 * height - CGFloat(index) * height
    }
}

    // MARK: - iOS 17 and Lower Implementation
struct MonthCalendarViewLegacy: View {
    @Binding var title: String
    @Binding var selection: Date
    @Binding var focused: Week
    let isDragging: Bool
    let dragProgress: CGFloat
    
    @State private var months: [Month]
    @State private var currentMonthId: String
    @State private var calendarWidth: CGFloat = .zero
    @State private var scrollToId: String?
    
    init(isDragging: Bool, dragProgress: CGFloat, title: Binding<String>, focused: Binding<Week>,
         selection: Binding<Date>) {
        self.isDragging = isDragging
        self.dragProgress = dragProgress
        _title = title
        _focused = focused
        _selection = selection
        
        let creationDate = focused.wrappedValue.days.last
        var currentMonth = Month(from: creationDate ?? .now, order: .current)
        
        let selection = selection.wrappedValue
        
        if let lastDayOfTheMonth = currentMonth.weeks.first?.days.last,
           !Calendar.isSameMonth(lastDayOfTheMonth, selection),
           let previousMonth = currentMonth.previousMonth
        {
        if focused.wrappedValue.days.contains(selection) {
            currentMonth = previousMonth
        }
        }
        
        let initialMonths = [
            currentMonth.previousMonth,
            currentMonth,
            currentMonth.nextMonth
        ].compactMap(\.self)
        
        _months = State(initialValue: initialMonths)
        _currentMonthId = State(initialValue: currentMonth.id)
        _scrollToId = State(initialValue: currentMonth.id)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: .zero) {
                    ForEach(months) { month in
                        VStack {
                            MonthView(
                                month: month,
                                dragProgress: dragProgress,
                                focused: $focused,
                                selectedDate: $selection
                            )
                            .offset(y: (1 - dragProgress) * verticalOffset(for: month))
                            .frame(width: calendarWidth, height: Constants.monthHeight)
                            .onAppear {
                                loadMonth(from: month)
                            }
                        }
                        .id(month.id)
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("scroll")).minX
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .scrollTargetLayout()
            .frame(height: Constants.monthHeight)
            .scrollDisabled(isDragging)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                updateCurrentMonth(offset: offset)
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
                proxy.scrollTo(currentMonthId, anchor: .center)
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
            let week = months.flatMap(\.weeks).first { week in
                week.days.contains(newValue)
            }
            
            if let week {
                focused = week
                if let month = months.first(where: { $0.weeks.contains(week) }) {
                    currentMonthId = month.id
                    scrollToId = month.id
                }
            }
        }
        .onChange(of: dragProgress) { _, newValue in
            guard newValue == 1 else { return }
            
            if let currentMonth = months.first(where: { $0.id == currentMonthId }),
               currentMonth.weeks.flatMap(\.days).contains(selection),
               let newFocus = currentMonth.weeks.first(where: { $0.days.contains(selection) })
            {
            focused = newFocus
            }
        }
    }
    
    private func updateCurrentMonth(offset: CGFloat) {
        guard calendarWidth > 0 else { return }
        
        let index = Int(round(-offset / calendarWidth))
        let safeIndex = max(0, min(index, months.count - 1))
        
        guard safeIndex < months.count else { return }
        
        let newMonth = months[safeIndex]
        
        if newMonth.id != currentMonthId {
            currentMonthId = newMonth.id
            
            guard let focusedWeek = newMonth.weeks.first else { return }
            
            if newMonth.weeks.flatMap(\.days).contains(selection),
               let selectedWeek = newMonth.weeks.first(where: { $0.days.contains(selection) })
            {
            focused = selectedWeek
            } else {
                focused = focusedWeek
            }
            
            if let lastDay = focusedWeek.days.last {
                title = Calendar.monthAndYear(from: lastDay)
            }
        }
    }
    
    func loadMonth(from month: Month) {
        if month.order == .previous, months.first == month, let previousMonth = month.previousMonth {
            var months = self.months
            months.insert(previousMonth, at: 0)
            self.months = months
        } else if month.order == .next, months.last == month, let nextMonth = month.nextMonth {
            var months = months
            months.append(nextMonth)
            self.months = months
        }
    }
    
    func verticalOffset(for month: Month) -> CGFloat {
        guard let index = month.weeks.firstIndex(where: { $0 == focused }) else { return .zero }
        let height = Constants.monthHeight / CGFloat(month.weeks.count)
        return CGFloat(month.weeks.count - 1) / 2 * height - CGFloat(index) * height
    }
}

    // MARK: - Preference Key for Legacy Implementation
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

    // MARK: - Preview
#Preview {
    MonthCalendarView(
        .constant(""),
        selection: .constant(.now),
        focused: .constant(.current),
        isDragging: false,
        dragProgress: 1
    )
}
