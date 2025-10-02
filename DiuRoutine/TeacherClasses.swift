
import SwiftUI

struct TeacherClasses: View {
    let selectedDate: Date?
    let mergedRoutines: [MergedRoutine]
    let hasSearchText: Bool
    let isValidTeacher: Bool
    
    @Namespace private var topID
    @State private var animateContent = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 0).id(topID)
                    contentView.padding(.horizontal)
                }
                .padding(.bottom, 150)
            }
            .onChange(of: selectedDate) { _, _ in
                    // Reset animation first
                animateContent = false
                scrollToTop(proxy: proxy)
                
                    // Trigger animation after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        animateContent = true
                    }
                }
            }
            .onChange(of: mergedRoutines.count) { _, _ in
                    // Also animate when routines change (important for when classes appear)
                animateContent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        animateContent = true
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    animateContent = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if mergedRoutines.isEmpty {
            emptyStateView
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.9)
        } else {
            routinesList
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.9)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: getEmptyStateIcon())
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            
            Text(getEmptyStateText())
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    private func getEmptyStateIcon() -> String {
        if !hasSearchText {
            return "calendar.badge.clock"
        } else if !isValidTeacher {
            return "exclamationmark.magnifyingglass"
        } else {
            return "magnifyingglass"
        }
    }
    
    private func getEmptyStateText() -> String {
        if !hasSearchText {
            return "Search by teacher to view classes"
        } else if !isValidTeacher {
            return "Invalid teacher. Please enter a valid teacher."
        } else {
            return "No class found"
        }
    }
    
    private var routinesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(mergedRoutines.enumerated()), id: \.element.id) { index, mergedRoutine in
                TeacherClassCard(mergedRoutine: mergedRoutine)
            }
        }
    }
    
    private func scrollToTop(proxy: ScrollViewProxy) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            proxy.scrollTo(topID, anchor: .top)
        }
    }
}


//#Preview {
//    TeacherClasses()
//}
