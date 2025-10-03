
import SwiftUI
import Lottie

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
        VStack(alignment: .center, spacing: 12) {
            getEmptyStateAnimation()
            Text(getEmptyStateText())
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private func getEmptyStateAnimation() -> some View {
        if !hasSearchText {
            LottieHelperView(fileName: "teach.json", contentMode: .scaleAspectFit, playLoopMode: .loop, speed: 0.5)
                .frame(maxHeight: 350).padding(.top, 40)
            
        } else if !isValidTeacher {
            LottieHelperView(fileName: "notfound.json", contentMode: .scaleAspectFit, playLoopMode: .loop, speed: 0.5)
                .frame(maxHeight: 350).padding(.top, 50)
        } else {
            LottieHelperView(fileName: "medi.json", contentMode: .scaleAspectFit, playLoopMode: .loop)
                .frame(maxHeight: 300)
        }
    }
    
    private func getEmptyStateText() -> String {
        if !hasSearchText {
            return "Search by inital to view routine"
        } else if !isValidTeacher {
            return "No teacher found for that search"
        } else {
            return "No class Today"
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
