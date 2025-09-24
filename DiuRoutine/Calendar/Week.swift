//
//  Week.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 23/9/25.
//

import Foundation

struct Week: Hashable, Identifiable {
    let id: String
    let days: [Date]
    let order: Order
    
    init(days: [Date], order: Order) {
        self.id = Calendar.weekAndYear(from: days.last ?? .now)
        self.days = days
        self.order = order
    }
    
    enum Order {
        case previous, current, next
    }
}


extension Week: Equatable {
    static func ==(lhs: Week, rhs: Week) -> Bool {
        lhs.id == rhs.id
    }
}

extension Week {
    static let current = Week(days: Calendar.currentWeek(from: Calendar.nearestMonday(from: .now)), order: .current)
}
