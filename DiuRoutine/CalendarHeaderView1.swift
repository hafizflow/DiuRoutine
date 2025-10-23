import SwiftUI

struct CalendarHeaderView1: View {
    @Binding var selectedDate: Date
    @State private var title: String = Calendar.monthAndYear(from: .now)
    @State private var focusedWeek: Week = .current
    @State private var calendarType: CalendarType = .week
    @State private var isDragging: Bool = false
    @State private var dragProgress: CGFloat = .zero
    @State private var initialDragOffset: CGFloat? = nil
    @State private var verticalDragOffset: CGFloat = .zero
    @Environment(\.colorScheme) var colorScheme
    
    private let symbols = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    
    enum CalendarType {
        case week, month
    }
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    private func getWeekdayIndex(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday % 7
    }
    
    private func shouldHighlightSymbol(at index: Int) -> Bool {
        let selection = selectedDate
        return getWeekdayIndex(for: selection) == index
    }
    
    private var symbolColor: Color {
        return colorScheme == .light ? .black : .teal
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.title2.bold()).foregroundStyle(.primary.opacity(0.8))
                Spacer()
                Text(selectedDate, format: .dateTime.day().weekday(.wide))
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.8))
            }
            .padding(.bottom)
            .padding(.horizontal, 24)
            
            HStack {
                ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                    Text(symbol)
                        .fontWeight(shouldHighlightSymbol(at: index) ? .semibold : .medium)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(shouldHighlightSymbol(at: index) ? symbolColor : .secondary)
                    
                    if symbol != symbols.last {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            
                // Calendar content
            VStack {
                switch calendarType {
                    case .week:
                        WeekCalendarView(
                            $title,
                            selection: $selectedDate,
                            focused: $focusedWeek,
                            isDragging: isDragging
                        )
                    case .month:
                        MonthCalendarView(
                            $title,
                            selection: $selectedDate,
                            focused: $focusedWeek,
                            isDragging: isDragging,
                            dragProgress: dragProgress
                        )
                }
            }
            .frame(height: Constants.dayHeight + verticalDragOffset)
            .clipped()
            
                // Drag indicator
            Capsule()
                .fill(mixedGrayColor())
                .frame(width: 40, height: 4)
                .padding(.bottom, 8)
                .padding(.top, Constants.defaultPadding - 4)
        }
        .onChange(of: selectedDate) { _, newValue in
            title = Calendar.monthAndYear(from: newValue)
        }
        .gesture(
            DragGesture(minimumDistance: .zero)
                .onChanged { value in
                    isDragging = true
                    calendarType = verticalDragOffset == 0 ? .week : .month
                    
                    if initialDragOffset == nil {
                        initialDragOffset = verticalDragOffset
                    }
                    verticalDragOffset = max(
                        .zero,
                        min(
                            (initialDragOffset ?? 0) + value.translation.height,
                            Constants.monthHeight - Constants.dayHeight
                        )
                    )
                    
                    dragProgress = verticalDragOffset / (Constants.monthHeight - Constants.dayHeight)
                }
                .onEnded { value in
                    isDragging = false
                    initialDragOffset = nil
                    
                    withAnimation {
                        switch calendarType {
                            case .week:
                                if verticalDragOffset > Constants.monthHeight/3 {
                                    verticalDragOffset = Constants.monthHeight - Constants.dayHeight
                                } else {
                                    verticalDragOffset = 0
                                }
                            case .month:
                                if verticalDragOffset < Constants.monthHeight/3 {
                                    verticalDragOffset = 0
                                } else {
                                    verticalDragOffset = Constants.monthHeight - Constants.dayHeight
                                }
                        }
                        
                        dragProgress = verticalDragOffset / (Constants.monthHeight - Constants.dayHeight)
                    } completion: {
                        calendarType = verticalDragOffset == 0 ? .week : .month
                    }
                }
        )
        .padding(.bottom)
    }
    
    
        // Add this helper function somewhere in your view or as an extension
    private func mixedGrayColor() -> Color {
        if #available(iOS 18.0, *) {
            return .gray.mix(with: .secondary, by: 0.6)
        } else {
                // Fallback for iOS 17 and below
            return Color.gray.opacity(0.5)
        }
    }
}
