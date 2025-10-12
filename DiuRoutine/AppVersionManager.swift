import Foundation
import UIKit
import Combine

class AppVersionManager: ObservableObject {
    @Published var appStoreVersion: String?
    @Published var isLoadingVersion: Bool = false
    @Published var showUpdateSheet: Bool = false
    
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var versionStatus: String {
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
    
    var isUpdateAvailable: Bool {
        guard let storeVersion = appStoreVersion else { return false }
        return storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending
    }
    
    func fetchAppStoreVersion() async {
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
                    
                        // Show update sheet if new version is available
                    if isUpdateAvailable {
                        showUpdateSheet = true
                    }
                }
            }
        } catch {
            print("Failed to fetch App Store version: \(error)")
        }
    }
    
    func checkForUpdateAndOpen() async {
        await fetchAppStoreVersion()
        
        if isUpdateAvailable,
           let url = URL(string: "https://apps.apple.com/us/app/diu-routine-viewer/id6748752277") {
            await UIApplication.shared.open(url)
        }
    }
    
    func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/us/app/diu-routine-viewer/id6748752277") {
            UIApplication.shared.open(url)
        }
    }
}
