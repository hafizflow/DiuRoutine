import SwiftUI

struct ContentView: View {
    @State private var selection: Date? = .now
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
    
    private func getWeekdayIndex(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday % 7
    }
    
        // Helper function to check if a symbol should be highlighted
    private func shouldHighlightSymbol(at index: Int) -> Bool {
        guard let selection = selection else { return false }
        return getWeekdayIndex(for: selection) == index
    }
    
    private var symbolColor: Color {
        return colorScheme == .light ? .black : .teal
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.01).ignoresSafeArea()
            
            VStack {
                HStack {
                    Text(title).font(.title2.bold())
                    Spacer()
                    
                    // Back to today button
                    Button(action: {
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text("Today")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary, lineWidth: 1)
                            }
                        )
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                    }
                    
                }
                .padding(.bottom)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
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
                
                VStack {
                    switch calendarType {
                        case .week:
                            WeekCalendarView(
                                $title,
                                selection: $selection,
                                focused: $focusedWeek,
                                isDragging: isDragging,
                            )
                        case .month:
                            MonthCalendarView(
                                $title,
                                selection: $selection,
                                focused: $focusedWeek,
                                isDragging: isDragging,
                                dragProgress: dragProgress
                            )
                    }
                }
                .frame(height: Constants.dayHeight + verticalDragOffset)
                .clipped()
                
                Capsule()
                    .fill(.gray.mix(with: .secondary, by: 0.6))
                    .frame(width: 40, height: 4)
                    .padding(.bottom, 8)
                    .padding(.top, Constants.defaultPadding - 4)
            }
            .background(
                UnevenRoundedRectangle(
                    cornerRadii: .init(bottomLeading: 24, bottomTrailing: 24)
                )
                .fill(Color.gray.opacity(0.2))
                .ignoresSafeArea()
            )
            .onChange(of: selection) { _, newValue in
                guard let newValue else { return }
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
        }
    }
}

#Preview {
    ContentView()
}
