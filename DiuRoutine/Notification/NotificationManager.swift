import Combine
import UserNotifications
import Foundation


@MainActor
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var preference: NotificationPreference?
    
    private let preferenceKey = "notificationPreference"
    
    override init() {
        super.init()
        loadPreference()
        UNUserNotificationCenter.current().delegate = self
    }
    
        // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
        // MARK: - Preference Management
    func savePreference(_ pref: NotificationPreference) {
        self.preference = pref
        if let encoded = try? JSONEncoder().encode(pref) {
            UserDefaults.standard.set(encoded, forKey: preferenceKey)
        }
    }
    
    func loadPreference() {
        if let data = UserDefaults.standard.data(forKey: preferenceKey),
           let decoded = try? JSONDecoder().decode(NotificationPreference.self, from: data) {
            self.preference = decoded
        }
    }
    
    func clearPreference() {
        self.preference = nil
        UserDefaults.standard.removeObject(forKey: preferenceKey)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
        // MARK: - Schedule Notifications
    func scheduleNotifications(routines: [RoutineDO]) async -> Bool {
        guard let pref = preference, pref.isEnabled else { return false }
        
            // Request permission
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else { return false }
        } catch {
            return false
        }
        
            // Filter routines based on preference
        let filteredRoutines: [RoutineDO]
        
        switch pref.userType {
            case .student:
                if let subId = pref.subIdentifier {
                        // Filter for specific section variant (e.g., 61_N1)
                    filteredRoutines = routines.filter { routine in
                        routine.section == subId || routine.section == pref.identifier
                    }
                } else {
                        // Filter for main section only (e.g., 61_N)
                    filteredRoutines = routines.filter { routine in
                        routine.section == pref.identifier
                    }
                }
                
            case .teacher:
                filteredRoutines = routines.filter { routine in
                    routine.initial?.caseInsensitiveCompare(pref.identifier) == .orderedSame
                }
        }
        
        guard !filteredRoutines.isEmpty else { return false }
        
            // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
            // Schedule new notifications using merged routine logic
        await scheduleNotificationsForRoutines(filteredRoutines)
        
        return true
    }
    
    private func scheduleNotificationsForRoutines(_ routines: [RoutineDO]) async {
        let center = UNUserNotificationCenter.current()
        let timeOrder = ["08:30", "10:00", "11:30", "01:00", "02:30", "04:00"]
        
            // Group routines by day
        let groupedByDay = Dictionary(grouping: routines) { $0.day ?? "Unknown" }
        
        for (_, dayRoutines) in groupedByDay {
                // Define grouping key based on user type
            struct GroupKey: Hashable {
                let section: String
                let code: String
                let initial: String
            }
            
            let grouped: [GroupKey: [RoutineDO]]
            
            if preference?.userType == .student {
                    // For students: group by course+section+teacher (merge consecutive classes with same teacher)
                grouped = Dictionary(grouping: dayRoutines) { routine in
                    GroupKey(
                        section: routine.section ?? "N/A",
                        code: routine.code ?? "N/A",
                        initial: routine.initial ?? "N/A"
                    )
                }
            } else {
                    // For teachers: group by course+section (merge consecutive classes for same section)
                grouped = Dictionary(grouping: dayRoutines) { routine in
                    GroupKey(
                        section: routine.section ?? "N/A",
                        code: routine.code ?? "N/A",
                        initial: "N/A" // Not used for teacher grouping
                    )
                }
            }
            
            for (_, group) in grouped {
                    // Sort by time
                let sorted = group.sorted { lhs, rhs in
                    guard let idx1 = timeOrder.firstIndex(of: lhs.startTime ?? ""),
                          let idx2 = timeOrder.firstIndex(of: rhs.startTime ?? "") else {
                        return (lhs.startTime ?? "") < (rhs.startTime ?? "")
                    }
                    return idx1 < idx2
                }
                
                guard let first = sorted.first,
                      let last = sorted.last,
                      let startTime = first.startTime,
                      let endTime = last.endTime,
                      let dayName = first.day else { continue }
                
                    // Parse start time and convert to 24-hour format
                let components = startTime.split(separator: ":")
                guard components.count == 2,
                      var hour = Int(components[0]),
                      let minute = Int(components[1]) else { continue }
                
                    // Convert to 24-hour format
                    // 08:30, 10:00, 11:30 are AM (keep as is)
                    // 01:00, 02:30, 04:00, 05:30 are PM (add 12)
                let amTimes = ["08:30", "10:00", "11:30"]
                if !amTimes.contains(startTime) {
                        // It's PM time, add 12 hours
                    hour += 12
                }
                
                    // Get course and teacher info
                let courseTitle = first.courseInfo?.title ?? "Class"
                let courseCode = first.code ?? "N/A"
                let teacherName = first.teacherInfo?.name ?? first.initial ?? "Teacher"
                let room = first.room ?? "TBA"
                let section = first.section ?? "N/A"
                
                    // Create notification content
                let content = UNMutableNotificationContent()
                content.title = "Class Starting in 15 Minutes"
                
                if preference?.userType == .student {
                    content.body = "Course: \(courseTitle) - \(courseCode)\n Room: \(room)\nTime: \(startTime) - \(endTime)\nSection: \(section)\nTeacher: \(teacherName)"
                } else {
                    content.body = "Course: \(courseTitle) - \(courseCode)\n Room: \(room)\nTime: \(startTime) - \(endTime)\nSection: \(section)\nTeacher: \(teacherName)"
                }
                
                content.sound = .default
                content.badge = 1
                
                    // Calculate notification time (15 minutes before)
                var notifMinute = minute - 15
                var notifHour = hour
                
                if notifMinute < 0 {
                    notifMinute += 60
                    notifHour -= 1
                }
                
                    // Create date components
                var dateComponents = DateComponents()
                dateComponents.weekday = weekdayNumber(from: dayName)
                dateComponents.hour = notifHour
                dateComponents.minute = notifMinute
                
                    // Create trigger (repeats weekly)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                    // Create unique identifier
                let identifier = "\(first.code ?? "")-\(first.section ?? "")-\(dayName)-\(startTime)"
                
                    // Create and add request
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                do {
                    try await center.add(request)
                } catch {
                        // Silently handle scheduling errors
                }
            }
        }
    }
    
    private func weekdayNumber(from dayName: String) -> Int {
        switch dayName.uppercased() {
            case "SUNDAY": return 1
            case "MONDAY": return 2
            case "TUESDAY": return 3
            case "WEDNESDAY": return 4
            case "THURSDAY": return 5
            case "FRIDAY": return 6
            case "SATURDAY": return 7
            default: return 1
        }
    }
}
