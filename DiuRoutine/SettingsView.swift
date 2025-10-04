import SwiftUI
import Toast


struct SettingsView: View {
    @State private var showShareSheet: Bool = false
    @State private var appStoreVersion: String?
    @State private var isLoadingVersion = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var studentRoutineStore: StudentRoutineStore
    @EnvironmentObject var teachertRoutineStore: TeacherRoutineStore
    @State private var showClearDataAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    SettingsSection(title: "Preferences") {
                        SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Push notifications") {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                
                                let config = ToastConfiguration(
                                    direction: .top,
                                    dismissBy: [.time(time: 3.0), .swipe(direction: .natural), .longPress],
                                    animationTime: 0.2,
                                    attachTo: window
                                )
                                
                                let toast = Toast.default(
                                    image: UIImage(systemName: "sparkles.2")!,
                                    title: "Comming Soon",
                                    subtitle: "Notificatio will be added soon",
                                    config: config
                                )
                                toast.show(haptic: .success)
                            }
                        }
                        
                        SettingsRow(icon: "moon.fill", title: "Dark Mode", subtitle: "Toggle dark mode") {
                                // Handle dark mode tap
                        }
                        
                        SettingsRow(icon: "arrow.trianglehead.2.clockwise.rotate.90.page.on.clipboard", title: "Clear Data", subtitle: "Clear Section/TI data") {
                            showClearDataAlert = true
                        }
                    }
                    
                    
                    SettingsSection(title: "About") {
                        SettingsRow(icon: "link", title: "Share app", subtitle: "Share app link with friends") {
                            showShareSheet = true
                        }
                        
                        SettingsRow(icon: "star.fill", title: "Rate & Feedback", subtitle: "Rate in App Store") {
                            if let url = URL(string: "https://apps.apple.com/us/app/diu-routine-viewer/id6748752277") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "App Info",
                            subtitle: versionSubtitle
                        ) {
                            Task {
                                await checkForUpdate()
                            }
                        }
                        
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", subtitle: "Get help") {
                                // Handle help tap
                        }
                    }
                }
                .padding()
                .padding(.horizontal, 8)
            }
            .alert("Clear Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }.tint(.primary).contentShape(Rectangle())
                Button("Clear", role: .destructive) {
                    studentRoutineStore.clearData()
                    teachertRoutineStore.clearData()
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        
                        let config = ToastConfiguration(
                            direction: .top,
                            dismissBy: [.time(time: 3.0), .swipe(direction: .natural), .longPress],
                            animationTime: 0.2,
                            attachTo: window
                        )
                        
                        let toast = Toast.default(
                            image: UIImage(systemName: "trash")!,
                            title: "Data Cleared Successfully",
                            subtitle: "All stored data has been removed",
                            config: config
                        )
                        toast.show(haptic: .success)
                    }
                }
            } message: {
                Text("Are you sure you want to clear all stored data?")
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings").font(.title.bold())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "multiply") {
                        dismiss()
                    }.tint(.primary).contentShape(Rectangle())
                    
                    
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [
                    "Check out this awesome app!",
                    URL(string: "https://apps.apple.com/us/app/diu-routine-viewer/id6748752277")!
                ])
                .presentationDetents([.medium])
            }
            .task(priority: .background) {
                await fetchAppStoreVersion()
            }
        }
    }
    
    private var versionSubtitle: String {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        
        if isLoadingVersion {
            return "Version \(currentVersion) • Checking..."
        }
        
        if let storeVersion = appStoreVersion {
            if storeVersion != currentVersion {
                return "Version \(currentVersion) • Update available: \(storeVersion)"
            } else {
                return "Version \(currentVersion) • Up to date"
            }
        }
        
        return "Version \(currentVersion)"
    }
    
    private func fetchAppStoreVersion() async {
        await MainActor.run { isLoadingVersion = true }
        defer { Task { await MainActor.run { isLoadingVersion = false } } }
        
        guard let bundleID = Bundle.main.bundleIdentifier,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)") else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let firstResult = results.first,
               let version = firstResult["version"] as? String {
                await MainActor.run {
                    appStoreVersion = version
                }
            }
        } catch {
            print("Failed to fetch App Store version: \(error)")
        }
    }
    
    private func checkForUpdate() async {
        await fetchAppStoreVersion()
        
        guard let storeVersion = appStoreVersion,
              let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        if storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                // Update available - you can show an alert here if needed
            if let url = URL(string: "https://apps.apple.com/us/app/diu-routine-viewer/id6748752277") {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(StudentRoutineStore())
        .environmentObject(TeacherRoutineStore())
}


struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
            
            VStack(spacing: 1) {
                content
            }
            .cornerRadius(16)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.8) : .teal)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .teal)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(colorScheme == .dark ? .white.opacity(0.15) : .gray.opacity(0.1))
        }
        .buttonStyle(.plain)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
            // Handle iPad popover
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
