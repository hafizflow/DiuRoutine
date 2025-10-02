import SwiftUI

struct TeacherData {
    let name: String
    let initial: String
    let designation: String
    let phone: String
    let email: String
    let room: String
    let imageUrl: String
}

struct TeacherInsights: View {
    let searchedTeacher: String
    let sections: [String]
    let totalCoursesEnrolled: Int
    let totalWeeklyClasses: Int
    let totalWeeklyHours: String
    let courses: [(title: String, code: String)]
    let teacher: TeacherData
    
        // ✅ Fallback values declared once
    private var teacherName: String { teacher.name.isEmpty ? "Unknown Teacher" : teacher.name }
    private var teacherDesignation: String { teacher.designation.isEmpty ? "N/A" : teacher.designation }
    private var teacherEmail: String { teacher.email.isEmpty || teacher.email == "N/A" ? "N/A" : teacher.email }
    private var teacherPhone: String { teacher.phone.isEmpty || teacher.phone == "N/A" ? "N/A" : teacher.phone }
    private var teacherRoom: String { teacher.room.isEmpty || teacher.room == "N/A" ? "N/A" : teacher.room }
    private var teacherImageUrl: String { teacher.imageUrl.isEmpty ? "https://via.placeholder.com/55" : teacher.imageUrl }
    
        // Helper computed properties
    private var hasValidPhone: Bool { teacherPhone != "N/A" }
    private var hasValidEmail: Bool { teacherEmail != "N/A" }
    
    init(
        searchedTeacher: String = "",
        sections: [String] = [],
        totalCoursesEnrolled: Int = 0,
        totalWeeklyClasses: Int = 0,
        totalWeeklyHours: String = "0h 0m",
        courses: [(title: String, code: String)],
        teacher: TeacherData
    ) {
        self.searchedTeacher = searchedTeacher
        self.sections = sections
        self.totalCoursesEnrolled = totalCoursesEnrolled
        self.totalWeeklyClasses = totalWeeklyClasses
        self.totalWeeklyHours = totalWeeklyHours
        self.courses = courses
        self.teacher = teacher
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Initial:")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                
                                Text(searchedTeacher)
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                            
                            HStack {
                                Text("Sections:")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                Text(sections.joined(separator: ", "))
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                        }
                        Spacer()
                        ZStack(alignment: .center) {
                            Button(action: {
                                    // Download PDF
                            }) {
                                ZStack(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.teal.opacity(0.1))
                                        .frame(height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                                        )
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Image(systemName: "arrow.down.app.fill")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.teal)
                                            .brightness(-0.1)
                                        
                                        Text("PDF")
                                            .lineLimit(1)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 10))
                                            .foregroundStyle(.teal)
                                            .fontWeight(.bold)
                                            .brightness(-0.1)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: 70)
                    }
                    .padding(.bottom, 32)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(teacherName)
                            .lineLimit(1)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                            .padding(.bottom, 0)
                        
                        Divider()
                            .frame(width: 150, height: 1)
                            .background(.gray.opacity(0.45))
                            .padding(.bottom, 4)
                        
                        HStack(spacing: 16) {
                            if let url = URL(string: teacherImageUrl), !teacherImageUrl.isEmpty {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                        case .empty:
                                            Circle()
                                                .fill(.gray.opacity(0.3))
                                                .frame(width: 55, height: 55)
                                                .overlay(ProgressView())
                                            
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 55, height: 55)
                                                .clipShape(Circle())
                                                .transition(.opacity.combined(with: .scale))
                                                .animation(.easeInOut, value: UUID())
                                            
                                        case .failure(_):
                                            Circle()
                                                .fill(.gray.opacity(0.3))
                                                .frame(width: 55, height: 55)
                                                .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
                                            
                                        @unknown default:
                                            EmptyView()
                                    }
                                }
                            } else {
                                Circle()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 55, height: 55)
                                    .overlay(Image(systemName: "person.fill").foregroundStyle(.gray))
                            }
                            
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("Desig: ")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.gray)
                                    
                                    Text(teacherDesignation)
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary.opacity(0.8))
                                }
                                
                                HStack(alignment: .center, spacing: 0) {
                                    Text("Phone: ")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.gray)
                                    
                                    if hasValidPhone {
                                        Link(teacherPhone, destination: URL(string: "tel:\(teacherPhone)")!)
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.teal.opacity(0.7))
                                    } else {
                                        Text(teacherPhone)
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    if hasValidPhone {
                                        Button(action: {
                                            UIPasteboard.general.string = teacherPhone
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                        }) {
                                            Image(systemName: "square.on.square")
                                                .foregroundColor(.teal.opacity(0.7))
                                                .font(.system(size: 16))
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack (alignment: .center, spacing: 0){
                            Text("Email: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            if hasValidEmail {
                                Text(teacherEmail)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary.opacity(0.8))
                                    .textSelection(.enabled)
                            } else {
                                Text(teacherEmail)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            if hasValidEmail {
                                Button(action: {
                                    UIPasteboard.general.string = teacherEmail
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }) {
                                    Image(systemName: "square.on.square")
                                        .foregroundColor(.teal.opacity(0.7))
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        
                        HStack (alignment: .center, spacing: 0){
                            Text("Room: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text(teacherRoom)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    VStack(spacing: 8) {
                        Text("Provided Courses")
                            .lineLimit(1)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                            .padding(.bottom, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ForEach(courses, id: \.code) { course in
                            HStack(alignment: .center) {
                                Text(course.title)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text(course.code)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ], spacing: 16) {
                        
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            Text("Total Course Provided: \(totalCoursesEnrolled)")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 12))
                                .foregroundStyle(.primary.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .lineSpacing(4)
                        }
                        
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            Text("Total Weekly Classes: \(totalWeeklyClasses)")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 12))
                                .foregroundStyle(.primary.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .lineSpacing(4)
                        }
                        
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            Text("Weekly Class Hours: \(totalWeeklyHours)")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 12))
                                .foregroundStyle(.primary.opacity(0.8))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("Insights").font(.title2.bold())
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "magnifyingglass") {
                        
                    }.tint(.primary).contentShape(Rectangle())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "multiply") {
                        dismiss()
                    }.tint(.primary).contentShape(Rectangle())
                }
            }
        }
    }
}
