//
//  TeacherClassCard.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 1/10/25.
//

import SwiftUI

struct TeacherClassCard: View {
    let mergedRoutine: MergedRoutine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("\(format12Hour(mergedRoutine.startTime)) - \(format12Hour(mergedRoutine.endTime))")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.2)
                
                Spacer()
                
                Text(calculateDuration(from: mergedRoutine.startTime, to: mergedRoutine.endTime))
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            OverFlowingText(text: mergedRoutine.courseTitle)
            
            HStack {
                HStack(alignment: .center, spacing: 10) {
                    Text("Section:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(mergedRoutine.section)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 20) {
                    Text("CCode:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(mergedRoutine.courseCode)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
            
            HStack(alignment: .center, spacing: 10) {
                Text("Room:")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(mergedRoutine.room)
                    .lineLimit(1)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
        .lineLimit(1)
        .padding()
        .background(.secondary.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


