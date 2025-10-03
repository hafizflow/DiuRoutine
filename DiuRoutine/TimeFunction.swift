//
//  TimeFunction.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 3/10/25.
//

import SwiftUI

func format12Hour(_ time: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm"
    guard let date = formatter.date(from: time) else { return time }
    
    let calendar = Calendar.current
    var comps = calendar.dateComponents([.hour, .minute], from: date)
    
    if let hour = comps.hour, hour < 8 {
        comps.hour = hour + 12
    }
    let adjustedDate = calendar.date(from: comps) ?? date
    
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: adjustedDate)
}

func calculateDuration(from startTime: String, to endTime: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm"
    
    func normalize(_ time: String) -> Int? {
        guard let date = formatter.date(from: time) else { return nil }
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        if hour < 8 {
            hour += 12
        }
        return hour * 60 + minute
    }
    
    guard let start = normalize(startTime),
          let end = normalize(endTime) else {
        return "N/A"
    }
    
    let duration = end - start
    guard duration > 0 else { return "N/A" }
    
    let hours = duration / 60
    let minutes = duration % 60
    
    if hours > 0 && minutes > 0 {
        return "\(hours)h \(minutes)m"
    } else if hours > 0 {
        return "\(hours)h"
    } else {
        return "\(minutes)m"
    }
}

func calculateDurationMinutes(from startTime: String, to endTime: String) -> Int {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm"
    
    func normalize(_ time: String) -> Int? {
        guard let date = formatter.date(from: time) else { return nil }
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        if hour < 8 {
            hour += 12
        }
        return hour * 60 + minute
    }
    
    guard let start = normalize(startTime),
          let end = normalize(endTime) else {
        return 0
    }
    
    return max(0, end - start)
}
