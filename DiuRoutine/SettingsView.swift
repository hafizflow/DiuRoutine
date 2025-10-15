import SwiftUI
import Toast
import SwiftData
import WebKit
import StoreKit

struct SettingsView: View {
    @State private var showShareSheet: Bool = false
    @State private var appStoreVersion: String?
    @State private var isLoadingVersion: Bool = false
    @State private var changeTheme: Bool = false
    @Environment(\.dismiss) var dismiss
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @Environment(\.colorScheme) private var scheme
    @AppStorage("cStyle") private var cStyle: Bool = true
    
    @StateObject private var routineVersionStore = RoutineVersionStore()
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var isNotificationsOn: Bool = NotificationManager.shared.preference?.isEnabled ?? true
    @Query private var routines: [RoutineDO]
    @State private var showWebView: Bool = false

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    SettingsSection(title: "Preferences") {
                            // Notification
                        NavigationLink {
                            NotificationOnboardingView()
                                .environmentObject(routineVersionStore)
                                .environmentObject(notificationManager)
                        } label: {
                            HStack(spacing: 15) {
                                Image(systemName: "bell.fill")
                                    .font(.title2)
                                    .foregroundStyle(scheme == .dark ? .white.opacity(0.8) : .teal)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notifications")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(scheme == .dark ? .white : .black)
                                    
                                    Text("Push notifications")
                                        .font(.caption)
                                        .foregroundStyle(scheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
                                }
                                
                                Spacer()
                                

                                if NotificationManager.shared.preference != nil {
                                    Toggle(isOn: $isNotificationsOn) {}
                                    .onChange(of: isNotificationsOn) { _, newValue in
                                        Task {
                                            var currentPref = NotificationManager.shared.preference
                                            currentPref?.isEnabled = newValue
                                            if let updated = currentPref {
                                                NotificationManager.shared.savePreference(updated)
                                                if newValue {
                                                    _ = await NotificationManager.shared.scheduleNotifications(routines: routines)
                                                } else {
                                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(scheme == .dark ? .white.opacity(0.4) : .teal)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(scheme == .dark ? Color.secondary.opacity(0.2) : Color.gray.opacity(0.1))
                        }
                        .buttonStyle(.plain)
                        
                        
                        // Dark Mode
                        SettingsRow(icon: "moon.fill", title: "Dark Mode", subtitle: "Toggle dark mode") {
                                changeTheme = true
                        }
                        
                        // CStyle
                        SettingsRow(icon: "calendar.badge.plus", title: "Calender Option", subtitle: "Change calender style") {
                            cStyle.toggle()
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                
                                let config = ToastConfiguration(
                                    direction: .top,
                                    dismissBy: [.time(time: 3.0), .swipe(direction: .natural), .longPress],
                                    animationTime: 0.2,
                                    attachTo: window
                                )
                                
                                let toast = Toast.default(
                                    image: UIImage(systemName: cStyle ? "calendar" : "ellipsis.calendar")!,
                                    title: "Calender Style Changed",
                                    subtitle: "Calender Style is now \(cStyle ? "Default" : "Standard")",
                                    config: config
                                )
                                toast.show(haptic: .success)
                            }
                        }
                    }
                    
                    
                    SettingsSection(title: "About") {
                        SettingsRow(icon: "link", title: "Share app", subtitle: "Share app link with friends") {
                            showShareSheet = true
                        }
                        
                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate & Feedback",
                            subtitle: "Rate in App Store"
                        ) {
                            if let url = URL(string: "https://apps.apple.com/app/id6748752277?action=write-review") {
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
                            showWebView = true
                        }
                    }
                }
                .padding()
                .padding(.horizontal, 8)
            }
            .preferredColorScheme(userTheme.colorScheme)
            .sheet(isPresented: $changeTheme, content: {
                ThemeChangeView(scheme: scheme)
                    .presentationDetents([.height(410)])
                    .presentationBackground(.clear)
            })
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
            .sheet(isPresented: $showWebView) {
                WebViewSheet()
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
            .background(colorScheme == .dark ? Color.secondary.opacity(0.2) : Color.gray.opacity(0.1))
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



struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let url = URL(string: "https://diuroutinesite.netlify.app")
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}


struct WebViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebView()
                .ignoresSafeArea()
            
            if #available(iOS 26.0, *) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 45, height: 45)
                        .glassEffect(.clear)
                        .clipShape(Circle())
                }
                .foregroundStyle(.white)
                .padding(.trailing, 16)
                .zIndex(1)
            } else {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 45, height: 45)
                        .background(Color(.systemGray5).opacity(0.8))
                        .clipShape(Circle())
                }
                .foregroundStyle(.white)
                .padding(.trailing, 16)
                .zIndex(1)
            }
        }
    }
}
