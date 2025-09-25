import Foundation

extension Calendar {
    static func nearestMonday(from date: Date = .now) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = weekday
        let theNearestMonday = calendar.date(byAdding: .day, value: -daysToSubtract, to: date)!
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: theNearestMonday)
        dateComponents.hour = 9
        dateComponents.minute = 0
        dateComponents.second = 0
        
        return Calendar.current.date(from: dateComponents) ?? theNearestMonday
    }
    
    static func currentWeek(from date: Date = .now) -> [Date] {
        let calendar = Calendar.current
        return (0...6).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: date)
        }
    }
    
    static func nextWeek(from date: Date = .now) -> [Date] {
        let calendar = Calendar.current
        return (1...7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: date)
        }
    }
    
    static func previousWeek(from date: Date = .now) -> [Date] {
        let calendar = Calendar.current
        return (1...7).compactMap { offset in
            calendar.date(byAdding: .day, value: -(6 - offset + 2), to: date)
        }
    }
    
    static func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    static func dayLetter(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
    
    static func weekAndYear(from date: Date) -> String {
        let calendar = Calendar.current
        let weekNumber = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.yearForWeekOfYear, from: date) // Handles ISO year
        return "\(weekNumber)_\(year)"
    }
    
    static func monthAndYear(from date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        let month = formatter.string(from: date)
        let year = calendar.component(.year, from: date)
        
        return "\(month) \(year)"
    }
    
    static func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month], from: date1)
        let components2 = calendar.dateComponents([.year, .month], from: date2)
        return components1.year == components2.year && components1.month == components2.month
    }
}

