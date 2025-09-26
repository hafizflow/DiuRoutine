import SwiftUI

    // MARK: - Teacher View with Calendar
struct TeacherView: View {
    @State private var selectedDate: Date? = .now
    
    var body: some View {
        VStack(spacing: 0) {
                // Calendar header
            CalendarHeaderView(selectedDate: $selectedDate)
            
                // Teacher content
            ScrollView {
                VStack(spacing: 16) {
                    TeacherScheduleCard(selectedDate: selectedDate)
                    TeacherClassesCard()
                    TeacherStudentsCard()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    TeacherView()
}



struct TeacherClassesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.indigo)
                Text("My Classes")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ClassItem(name: "Advanced Mathematics", grade: "Grade 12", students: 28)
                ClassItem(name: "Algebra", grade: "Grade 10", students: 32)
                ClassItem(name: "Calculus", grade: "Grade 11", students: 24)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TeacherStudentsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.mint)
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• John Doe submitted Math Assignment")
                    .font(.subheadline)
                Text("• Sarah Smith requested help with Physics")
                    .font(.subheadline)
                Text("• Mike Johnson completed Lab Report")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}



struct TeacherScheduleCard: View {
    let selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                Text("Teaching Schedule")
                    .font(.headline)
                Spacer()
                if let date = selectedDate {
                    Text(date, format: .dateTime.weekday(.wide).month().day())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ScheduleItem(time: "8:00 AM", subject: "Advanced Math - Grade 12", room: "Room 201")
                ScheduleItem(time: "10:00 AM", subject: "Algebra - Grade 10", room: "Room 201")
                ScheduleItem(time: "1:00 PM", subject: "Calculus - Grade 11", room: "Room 201")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}




struct ScheduleItem: View {
    let time: String
    let subject: String
    let room: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(time)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                Text(room)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .leading)
            
            Text(subject)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AssignmentItem: View {
    let title: String
    let dueDate: String
    let status: AssignmentStatus
    
    enum AssignmentStatus {
        case pending, completed, overdue
        
        var color: Color {
            switch self {
                case .pending: return .orange
                case .completed: return .green
                case .overdue: return .red
            }
        }
        
        var text: String {
            switch self {
                case .pending: return "Pending"
                case .completed: return "Completed"
                case .overdue: return "Overdue"
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                Text("Due: \(dueDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(status.text)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(status.color.opacity(0.2))
                .foregroundColor(status.color)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

struct ClassItem: View {
    let name: String
    let grade: String
    let students: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline.bold())
                Text(grade)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(students) students")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct GradeItem: View {
    let subject: String
    let grade: String
    let percentage: String
    
    var body: some View {
        HStack {
            Text(subject)
                .font(.subheadline)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(grade)
                    .font(.subheadline.bold())
                Text(percentage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
