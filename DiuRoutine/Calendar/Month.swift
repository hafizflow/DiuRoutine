import Foundation

struct Month: Identifiable, Equatable {
    let id: String
    let weeks: [Week]
    let order: Order
    let initializedDate: Date
    
    init(from date: Date, order: Order) {
        self.order = order
        
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.day = 15
        components.hour = 9
        components.minute = 0
        components.second = 0
        
        initializedDate = Calendar.current.date(from: components) ?? date
        
        let nearestMonday = Calendar.nearestSaturday(from: initializedDate)
        let currentWeekDays = Calendar.currentWeek(from: nearestMonday)
        
        var weeks: [Week] = [
            Week(days: currentWeekDays, order: .current)
        ]
        
        var reachedLowerBound: Bool = false
        repeat {
            guard let week = weeks.first,
                  let firstDay = week.days.first,
                  let lastDay = week.days.last,
                  Calendar.isSameMonth(firstDay, lastDay)
            else {
                break
            }
            
            if let firstDay = weeks.first?.days.first {
                let previousWeekDays = Calendar.previousWeek(from: firstDay)
                
                if let lastDay = previousWeekDays.last, Calendar.isSameMonth(lastDay, firstDay) {
                    weeks.insert(Week(days: previousWeekDays, order: .previous), at: 0)
                }
                
                if let previousFirstDate = previousWeekDays.first, !Calendar.isSameMonth(previousFirstDate, firstDay) {
                    reachedLowerBound = true
                }
            } else {
                reachedLowerBound = true
            }
        } while !reachedLowerBound
            
            
        
        var reachedUpperBound: Bool = false
        repeat {
            if let lastDay = weeks.last?.days.last {
                let nextWeekDays = Calendar.nextWeek(from: lastDay)
                
                if let firstDay = nextWeekDays.first, Calendar.isSameMonth(firstDay, lastDay) {
                    weeks.append(Week(days: nextWeekDays, order: .next))
                }
                
                if let nextLastDate = nextWeekDays.last, !Calendar.isSameMonth(nextLastDate, lastDay) {
                    reachedUpperBound = true
                }
            } else {
                reachedUpperBound = true
            }
        } while !reachedUpperBound
        
        self.weeks = weeks
        self.id = Calendar.monthAndYear(from: initializedDate)
    }
}

extension Month {
    enum Order {
        case previous, current, next
    }
    
    var previousMonth: Month? {
        guard let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: initializedDate) else { return nil }
        return Month(from: previousMonthDate, order: .previous)
    }
    
    var nextMonth: Month? {
        guard let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: initializedDate) else { return nil }
        return Month(from: nextMonthDate, order: .next)
    }
    
    func theSameMonth(as date: Date) -> Bool {
        Calendar.isSameMonth(initializedDate, date)
    }
}

