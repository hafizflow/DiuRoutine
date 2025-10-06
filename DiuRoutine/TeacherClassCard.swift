import SwiftUI

struct TeacherClassCard: View {
    let mergedRoutine: MergedRoutine
    @Environment(\.colorScheme) var colorScheme
    
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
                    .background(.secondary.opacity(colorScheme == .dark ? 0.15 : 0.1))
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
        .background(
            colorScheme == .dark
            ? Color.secondary.opacity(0.15)
            : Color.clear
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.gray.opacity(0.25),
                    lineWidth: 2
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
