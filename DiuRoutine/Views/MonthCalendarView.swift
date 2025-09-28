import SwiftUI

struct MonthCalendarView: View {
    let isDragging: Bool
    let dragProgress: CGFloat
    
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date?
    
    @State private var months: [Month]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(_ title: Binding<String>, selection: Binding<Date?>, focused: Binding<Week>, isDragging: Bool,
         dragProgress: CGFloat) {
            _title = title
            _focused = focused
            _selection = selection
            self.isDragging = isDragging
            self.dragProgress = dragProgress
        
            let creationDate = focused.wrappedValue.days.last
            var currentMonth = Month(from: creationDate ?? .now, order: .current)
            
            if let selection = selection.wrappedValue,
               let lastDayOfTheMonth = currentMonth.weeks.first?.days.last,
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
        ScrollView(.horizontal){
            LazyHStack(spacing:.zero){
                ForEach(months) { month in
                    VStack{
                        MonthView(month: month, dragProgress: dragProgress, focused: $focused, selectedDate:
                                    $selection)
                        .offset(y: (1 - dragProgress) * verticalOffset(for: month))
                        .frame(width: calendarWidth, height: Constants.monthHeight)
                        .onAppear{loadMonth(from: month)}
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
            
            if
                let selection,
                focusedMonth.weeks.flatMap(\.days).contains(selection),
                let selectedWeek = focusedMonth.weeks.first(where: { $0.days.contains(selection) })
            {
            focused = selectedWeek
            } else {
                focused = focusedWeek
            }
            
            title = Calendar.monthAndYear(from: focusedWeek.days.last!)
        }
        .onChange(of: selection) { _, newValue in
            guard let date = newValue,
                  let week = months.flatMap(\.weeks).first(where: { (week) -> Bool in
                      week.days.contains(date)
                  })
            else { return }
            focused = week
        }
        .onChange(of: dragProgress) { _, newValue in
            guard newValue == 1 else { return }
            if let selection,
               let currentMonth = months.first(where: { $0.id == (position.viewID as? String) }),
               currentMonth.weeks.flatMap(\.days).contains(selection),
               let newFocus = currentMonth.weeks.first(where: { $0.days.contains(selection) })
            {
            focused = newFocus
            }
        }
    }
}


extension MonthCalendarView {
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
        let height = Constants.monthHeight/CGFloat(month.weeks.count)
        return CGFloat(month.weeks.count - 1)/2 * height - CGFloat(index) * height
    }
}

#Preview {
    MonthCalendarView(
        .constant(""),
        selection: .constant(.now),
        focused: .constant(.current),
        isDragging: false,
        dragProgress: 1
    )
}

