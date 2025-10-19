import SwiftUI
import Toast

struct MergedRoutine: Identifiable {
    let id = UUID()
    let startTime: String
    var endTime: String
    let courseTitle: String
    let courseCode: String
    let section: String
    let teacherInitial: String
    let teacherName: String
    let teacherDesignation: String
    let teacherRoom: String
    let teacherCell: String
    let teacherEmail: String
    let teacherImageUrl: String
    let room: String
    var routines: [RoutineDO]
    
    var duration: String {
        return calculateDuration(from: startTime, to: endTime)
    }
}


struct StudentClassCard: View {
    let mergedRoutine: MergedRoutine
    private let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
    
    
        // ✅ Fallback values declared once
    private var teacherName: String { mergedRoutine.teacherName.isEmpty ? "Unknown Teacher" : mergedRoutine.teacherName }
    private var teacherDesignation: String { mergedRoutine.teacherDesignation.isEmpty ? "N/A" : mergedRoutine.teacherDesignation }
    private var teacherEmail: String { mergedRoutine.teacherEmail.isEmpty ? "N/A" : mergedRoutine.teacherEmail }
    private var teacherCell: String { mergedRoutine.teacherCell.isEmpty ? "N/A" : mergedRoutine.teacherCell }
    private var teacherRoom: String { mergedRoutine.teacherRoom.isEmpty ? "N/A" : mergedRoutine.teacherRoom }
    private var teacherInitial: String { mergedRoutine.teacherInitial.isEmpty ? "N/A" : mergedRoutine.teacherInitial }
    
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
                
                Text(mergedRoutine.duration)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(colorScheme == .dark ? 0.15 : 0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            OverFlowingText(text: "\(mergedRoutine.courseTitle) - \(mergedRoutine.courseCode)")
            
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
                
                HStack(alignment: .center, spacing: 10) {
                    Text("Teacher:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Menu {
                        Button(teacherName, systemImage: "") {}
                        Divider()
                        Button(teacherDesignation, systemImage: "person.text.rectangle") {}
                        Button(teacherEmail, systemImage: "envelope.fill") {
                            if mergedRoutine.teacherEmail.isEmpty { return } else {
                                UIPasteboard.general.string = mergedRoutine.teacherEmail
                                impactFeedback.impactOccurred()
                                
                                Toast.default(
                                    image: UIImage(systemName: "square.on.square.fill")!,
                                    title: mergedRoutine.teacherEmail,
                                    subtitle: "Copied in Clipboard"
                                )
                                .show()
                            }
                        }
                        Button(teacherCell, systemImage: "phone.fill") {
                            if mergedRoutine.teacherCell.isEmpty { return } else {
                                UIPasteboard.general.string = mergedRoutine.teacherCell
                                impactFeedback.impactOccurred()
                                
                                Toast.default(
                                    image: UIImage(systemName: "square.on.square.fill")!,
                                    title: mergedRoutine.teacherCell,
                                    subtitle: "Copied in Clipboard"
                                )
                                .show()
                            }
                        }
                        Button(teacherRoom, systemImage: "mappin.and.ellipse") {}
                    } label: {
                        Text(mergedRoutine.teacherInitial)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                    }
                    .menuOrder(.fixed)
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
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

    // Sample MergedRoutine for Preview
extension MergedRoutine {
    static var sampleData: MergedRoutine {
        MergedRoutine(
            startTime: "09:00",
            endTime: "10:30",
            courseTitle: "Object Oriented Programming",
            courseCode: "CSE 202",
            section: "A",
            teacherInitial: "SRJ",
            teacherName: "Dr. Sarah Johnson",
            teacherDesignation: "Professor",
            teacherRoom: "Faculty Room 301",
            teacherCell: "+1 (555) 123-4567",
            teacherEmail: "sarah.johnson@university.edu",
            teacherImageUrl: "",
            room: "Room 405",
            routines: []
        )
    }
}

    // Preview
#Preview {
    VStack(spacing: 16) {
        StudentClassCard(mergedRoutine: .sampleData)
    }
    .padding()
}

