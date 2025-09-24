//
//  DayView.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 23/9/25.
//

import SwiftUI

struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Text(Calendar.dayNumber(from: date))
                .background{
                    if date == selectedDate {
                        Circle()
                            .foregroundStyle(.teal)
                            .opacity(0.3)
                            .frame(width: 40, height: 40)
                    } else if Calendar.current.isDateInToday(date) {
                        Circle()
                            .foregroundStyle(.secondary)
                            .opacity(0.3)
                            .frame(width: 40, height: 40)
                    }
                }
        }
        .foregroundStyle(selectedTextColor)
        .font(.system(.body, design: .rounded, weight: date == selectedDate ? .semibold : .medium))
        .onTapGesture {
            withAnimation(.easeInOut) {
                selectedDate = date
            }
        }
    }
    
    private var selectedTextColor: Color {
        if selectedDate == date {
            return colorScheme == .light ? .black : .teal
        } else {
            return .primary
        }
    }
}

#Preview {
    DayView(date: .now, selectedDate: .constant(nil))
}
