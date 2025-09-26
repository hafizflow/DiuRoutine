import SwiftUI

struct StudentView: View {
    @State private var selectedDate: Date? = .now
    @State private var selectedSection: RoutineType = .routine
    
    enum RoutineType: String, CaseIterable, Identifiable {
        case routine, insights
        var id: Self { self }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView(selectedDate: $selectedDate)
            
            Picker("Section", selection: $selectedSection) {
                Text("Routine").tag(RoutineType.routine)
                Text("Insights").tag(RoutineType.insights)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            
            TabView(selection: $selectedSection) {
                RoutinePageView(selectedDate: selectedDate)
                    .tag(RoutineType.routine)
                
                InsightsPageView(selectedDate: selectedDate)
                    .tag(RoutineType.insights)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.interactiveSpring, value: selectedSection)
        }
    }
}

    // MARK: - Routine Page
struct RoutinePageView: View {
    let selectedDate: Date?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StudentCard(selectedDate: selectedDate)
            }
            .padding()
        }
    }
}

    // MARK: - Insights Page
struct InsightsPageView: View {
    let selectedDate: Date?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StudyInsightsCard()
            }
            .padding()
        }
    }
}

    // MARK: - Schedule Card (Updated)
struct StudentCard: View {
    let selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("08:30 - 10:00")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.2)
                
                Spacer()
                
                Text("1h 30min")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            OverflowingText(text: "Computer Science - CSE332")
            
            HStack {
                HStack(alignment: .center, spacing: 10) {
                    Text("Section:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text("61_N")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 20) {
                    Text("Teacher:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Button(action: {
                        
                    }) {
                        Text("MZJ")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
            
            HStack(alignment: .center, spacing: 10) {
                Text("Room:")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text("301")
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

    // MARK: - Insights Cards
struct StudyInsightsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.teal)
                Text("Study Insights")
                    .font(.headline)
                Spacer()
            }
        }
        .padding()
        .background(.secondary.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


struct OverflowingText: View {
    let text: String
    @State private var isOverflowing = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding([.top, .bottom], 6)
                    .lineLimit(1)
                    .brightness(-0.2)
                    .background(
                        GeometryReader { textGeo in
                            Color.clear
                                .onAppear {
                                    if textGeo.size.width > geo.size.width {
                                        isOverflowing = true
                                    }
                                }
                        }
                    )
            }
            .disabled(!isOverflowing)
        }
        .frame(height: 36)
    }
}

    // MARK: - Preview
#Preview("Student View") {
    NavigationView {
        StudentView()
    }
}
