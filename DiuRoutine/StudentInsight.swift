import SwiftUI

//struct StudentInsight: View {
//        // Placeholder values
//    let totalCoursesEnrolled = 5
//    let totalWeeklyClasses = 12
//    let totalWeeklyHours: Double = 18.5
//    let courses = [
//        (title: "Mathematics", code: "MATH101"),
//        (title: "Physics", code: "PHYS101"),
//        (title: "Chemistry", code: "CHEM101")
//    ]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        Text("Section: ")
//                            .font(.system(size: 16))
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.secondary)
//                        
//                        Text("61_N")
//                            .font(.system(size: 16))
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.primary.opacity(0.8))
//                    }
//                    
//                    HStack {
//                        Text("Routine Version: ")
//                            .font(.system(size: 16))
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.secondary)
//                        Text("2.0")
//                            .font(.system(size: 16))
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.primary.opacity(0.8))
//                    }
//                }
//                
//                Spacer()
//                
//                ZStack(alignment: .center) {
//                    Button(action: {
//                            // Download PDF
//                    }) {
//                        ZStack(alignment: .center) {
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(.teal.opacity(0.1))
//                                .frame(height: 60)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 15)
//                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
//                                )
//                            
//                            VStack(alignment: .center, spacing: 4) {
//                                Image(systemName: "arrow.down.app.fill")
//                                    .font(.title3)
//                                    .fontWeight(.semibold)
//                                    .foregroundStyle(.teal)
//                                    .brightness(-0.1)
//                                
//                                Text("PDF")
//                                    .lineLimit(1)
//                                    .multilineTextAlignment(.center)
//                                    .font(.system(size: 10))
//                                    .foregroundStyle(.teal)
//                                    .fontWeight(.bold)
//                                    .brightness(-0.1)
//                            }
//                        }
//                    }
//                }
//                .frame(maxWidth: 70)
//                
//            }
//            .padding(.bottom)
//            
//                // Enrolled courses
//            VStack(spacing: 8) {
//                Text("Enrolled Course")
//                    .font(.system(size: 20))
//                    .fontWeight(.bold)
//                    .foregroundStyle(.teal.opacity(0.9))
//                    .brightness(-0.1)
//                    .padding(.bottom, 6)
//                
//                ForEach(courses, id: \.code) { course in
//                    HStack(alignment: .center) {
//                        Text(course.title)
//                            .font(.system(size: 16))
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.secondary)
//                        Spacer()
//                        Text(course.code)
//                            .font(.system(size: 16))
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.primary.opacity(0.8))
//                    }
//                }
//            }
//            .padding(.bottom, 16)
//            
//            Divider()
//                .frame(height: 1)
//                .background(.gray.opacity(0.45))
//                .padding(.bottom, 16)
//            
//                // First row of stats
//            LazyVGrid(columns: [
//                GridItem(.flexible(), spacing: 12),
//                GridItem(.flexible(), spacing: 12),
//                GridItem(.flexible(), spacing: 12),
//            ], spacing: 16) {
//                
//                ZStack(alignment: .center) {
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(.windowBackground)
//                        .frame(height: 80)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(.gray.opacity(0.45), lineWidth: 1)
//                        )
//                    
//                    Text("Total Course Enrolled: \(totalCoursesEnrolled)")
//                        .lineLimit(2)
//                        .multilineTextAlignment(.center)
//                        .font(.system(size: 12))
//                        .foregroundStyle(.primary.opacity(0.8))
//                        .fontWeight(.bold)
//                        .padding(.horizontal, 8)
//                        .lineSpacing(4)
//                }
//                
//                ZStack(alignment: .center) {
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(.windowBackground)
//                        .frame(height: 80)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(.gray.opacity(0.45), lineWidth: 1)
//                        )
//                    
//                    Text("Total Weekly Classes: \(totalWeeklyClasses)")
//                        .lineLimit(2)
//                        .multilineTextAlignment(.center)
//                        .font(.system(size: 12))
//                        .foregroundStyle(.primary.opacity(0.8))
//                        .fontWeight(.bold)
//                        .padding(.horizontal, 8)
//                        .lineSpacing(4)
//                }
//                
//                ZStack(alignment: .center) {
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(.windowBackground)
//                        .frame(height: 80)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(.gray.opacity(0.45), lineWidth: 1)
//                        )
//                    
//                    Text("Weekly Class Hours: \(String(format: "%.1f", totalWeeklyHours))")
//                        .lineLimit(2)
//                        .multilineTextAlignment(.center)
//                        .font(.system(size: 12))
//                        .foregroundStyle(.primary.opacity(0.8))
//                        .fontWeight(.bold)
//                        .padding(.horizontal, 8)
//                        .lineSpacing(4)
//                }
//            }
//            .padding(.bottom, 8)
//
//        }
//        .lineLimit(1)
//        .padding(15)
//    }
//}

//#Preview {
//    StudentInsight()
//}
