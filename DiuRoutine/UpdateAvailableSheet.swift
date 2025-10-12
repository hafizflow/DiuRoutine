import SwiftUI

struct UpdateAvailableSheet: View {
    @EnvironmentObject var versionManager: AppVersionManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
                // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
                // Icon
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.teal.opacity(0.2) : Color.teal.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(colorScheme == .dark ? .teal : .teal)
            }
            .padding(.bottom, 24)
            
                // Title
            Text("Update Available")
                .font(.title2.bold())
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 8)
            
                // Version info
            if let newVersion = versionManager.appStoreVersion {
                Text("Version \(newVersion) is now available")
                    .font(.body)
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                    .padding(.bottom, 4)
                
                Text("You're currently on version \(versionManager.currentVersion)")
                    .font(.caption)
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                    .padding(.bottom, 32)
            }
            
                // Buttons
            VStack(spacing: 12) {
                    // Update button
                Button {
                    versionManager.showUpdateSheet = false
                } label: {
                    Text("Update Now")
                        .font(.body.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color.teal, Color.teal.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                }
                
                    // No thanks button
                Button {
                    versionManager.showUpdateSheet = false
                } label: {
                    Text("No Thanks")
                        .font(.body)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(colorScheme == .dark ? Color.secondary.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(uiColor: .systemBackground) : .white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

    // Helper for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    UpdateAvailableSheet()
        .environmentObject(AppVersionManager())
        .presentationDetents([.height(400)])
        .presentationBackground(.clear)
}
