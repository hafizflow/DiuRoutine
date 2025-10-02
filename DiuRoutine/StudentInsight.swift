import SwiftUI

struct TeacherInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let initial: String
    let imageUrl: String
    let designation: String
}

struct StudentInsight: View {
    let searchedSection: String
    let totalCoursesEnrolled: Int
    let totalWeeklyClasses: Int
    let totalWeeklyHours: String
    let courses: [(title: String, code: String)]
    let teachers: [TeacherInfo]
    
    @State private var versionStore = RoutineVersionStore()
    
    init(
        searchedSection: String = "",
        totalCoursesEnrolled: Int = 0,
        totalWeeklyClasses: Int = 0,
        totalWeeklyHours: String = "0h 0m",
        courses: [(title: String, code: String)],
        teachers: [TeacherInfo]
    ) {
        self.searchedSection = searchedSection
        self.totalCoursesEnrolled = totalCoursesEnrolled
        self.totalWeeklyClasses = totalWeeklyClasses
        self.totalWeeklyHours = totalWeeklyHours
        self.courses = courses
        self.teachers = teachers
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Section: ")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                
                                Text(searchedSection)
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                            
                            HStack {
                                Text("Version: ")
                                    .font(.headline.bold())
                                    .foregroundStyle(.gray)
                                Text(versionStore.routineVersion)
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
                    
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appointed Teachers")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.1)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ForEach(teachers) { teacher in
                            HStack(spacing: 12) {
                                if let url = URL(string: teacher.imageUrl), !teacher.imageUrl.isEmpty {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                            case .empty:
                                                Circle()
                                                    .fill(.gray.opacity(0.3))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(ProgressView())
                                                
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                                    .transition(.opacity.combined(with: .scale))
                                                    .animation(.easeInOut, value: UUID())
                                                
                                            case .failure(_):
                                                Circle()
                                                    .fill(.gray.opacity(0.3))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
                                                
                                            @unknown default:
                                                EmptyView()
                                        }
                                    }
                                } else {
                                    Circle()
                                        .fill(.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                        .overlay(Image(systemName: "person.fill").foregroundStyle(.gray))
                                }
                                
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(teacher.name) - \(teacher.initial)")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(teacher.designation)
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.vertical)
                    
                    VStack(spacing: 8) {
                        Text("Enrolled Courses")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.1)
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
                            
                            Text("Total Course Enrolled: \(totalCoursesEnrolled)")
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
                    Button("Settings", systemImage: "arrowshape.turn.up.right") {
                        
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


