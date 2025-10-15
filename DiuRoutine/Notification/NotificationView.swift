import SwiftUI
import SwiftData

struct NotificationPreference: Codable {
    var isEnabled: Bool
    var userType: UserType
    var identifier: String // section or teacher initial
    var subIdentifier: String? // for section variants like 61_N1, 61_N2
    
    enum UserType: String, Codable {
        case student
        case teacher
    }
}

struct NotificationOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var notificationManager = NotificationManager.shared
    @Query private var routines: [RoutineDO]
    
    @State private var currentStep: Step = .userType
    @State private var selectedUserType: NotificationPreference.UserType = .student
    @State private var searchText: String = ""
    @State private var selectedSection: String = ""
    @State private var selectedVariant: String? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showExistingPreference: Bool = false
    
    enum Step {
        case existingPreference
        case userType
        case input
        case variant
        case confirmation
    }
    
    init() {
        if let prefData = UserDefaults.standard.data(forKey: "notificationPreference"),
           let _ = try? JSONDecoder().decode(NotificationPreference.self, from: prefData) {
            _showExistingPreference = State(initialValue: true)
            _currentStep = State(initialValue: .existingPreference)
        }
    }
    
        // Get all sections
    private var allSections: [String] {
        let sections = routines.compactMap { $0.section }
        let mainSections = sections.compactMap { section -> String? in
            if let range = section.range(of: #"\d+$"#, options: .regularExpression) {
                return String(section[..<range.lowerBound])
            }
            return section
        }
        return Array(Set(mainSections)).sorted()
    }
    
        // Get section variants (e.g., 61_N1, 61_N2)
    private var sectionVariants: [String] {
        let variants = routines.compactMap { $0.section }
            .filter { $0.hasPrefix(selectedSection) && $0 != selectedSection }
        return Array(Set(variants)).sorted()
    }
    
        // Get all teachers
    private var allTeachers: [(name: String, initial: String)] {
        var seen = Set<String>()
        var teachers: [(name: String, initial: String)] = []
        
        for routine in routines {
            let initial = routine.initial ?? "N/A"
            if !seen.contains(initial) {
                seen.insert(initial)
                let name = routine.teacherInfo?.name ?? "Unknown"
                teachers.append((name, initial))
            }
        }
        return teachers.sorted { $0.name < $1.name }
    }
    
        // Validate input
    private func isValid() -> Bool {
        if selectedUserType == .student {
            return allSections.contains(where: { $0.caseInsensitiveCompare(searchText) == .orderedSame })
        } else {
            return allTeachers.contains { teacher in
                teacher.initial.caseInsensitiveCompare(searchText) == .orderedSame
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 30) {
                        // Progress indicator (hide for existing preference screen)
                    if currentStep != .existingPreference {
                        HStack(spacing: 8) {
                            ForEach(0..<(selectedUserType == .student ? 4 : 3), id: \.self) { index in
                                Capsule()
                                    .fill(stepIndex() >= index ? Color.accentColor : Color.gray.opacity(0.3))
                                    .frame(height: 4)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            switch currentStep {
                                case .existingPreference:
                                    ExistingPreferenceView(
                                        preference: notificationManager.preference,
                                        onKeep: { dismiss() },
                                        onChange: {
                                            notificationManager.clearPreference()
                                            currentStep = .userType
                                        }
                                    )
                                    
                                case .userType:
                                    UserTypeStepView(selectedUserType: $selectedUserType)
                                    
                                case .input:
                                    InputStepView(
                                        userType: selectedUserType,
                                        searchText: $searchText,
                                        allSections: allSections,
                                        allTeachers: allTeachers
                                    )
                                    
                                case .variant:
                                    VariantStepView(
                                        selectedSection: selectedSection,
                                        variants: sectionVariants,
                                        selectedVariant: $selectedVariant
                                    )
                                    
                                case .confirmation:
                                    ConfirmationStepView(
                                        userType: selectedUserType,
                                        identifier: selectedSection,
                                        variant: selectedVariant
                                    )
                            }
                        }
                        .padding()
                    }
                    
                        // Navigation buttons (hide for existing preference screen)
                    if currentStep != .existingPreference {
                        HStack(spacing: 15) {
                            if currentStep != .userType {
                                Button("Back") {
                                    goBack()
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                            }
                            
                            Button(currentStep == .confirmation ? "Enable Notifications" : "Next") {
                                goNext()
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                            .disabled(!canProceed())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Class Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if currentStep == .existingPreference {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Skip") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Invalid Input", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func stepIndex() -> Int {
        switch currentStep {
            case .existingPreference: return 0
            case .userType: return 0
            case .input: return 1
            case .variant: return 2
            case .confirmation: return selectedUserType == .student ? 3 : 2
        }
    }
    
    private func canProceed() -> Bool {
        switch currentStep {
            case .existingPreference:
                return false
            case .userType:
                return true
            case .input:
                return !searchText.isEmpty
            case .variant:
                return selectedVariant != nil
            case .confirmation:
                return true
        }
    }
    
    private func goNext() {
        switch currentStep {
            case .existingPreference:
                break
                
            case .userType:
                currentStep = .input
                
            case .input:
                    // Validate
                guard isValid() else {
                    errorMessage = selectedUserType == .student ? "Section not found. Please enter a valid section." : "Teacher not found. Please enter a valid initial."
                    showError = true
                    return
                }
                
                selectedSection = searchText
                
                    // Check for variants
                if selectedUserType == .student && !sectionVariants.isEmpty {
                    currentStep = .variant
                } else {
                    currentStep = .confirmation
                }
                
            case .variant:
                currentStep = .confirmation
                
            case .confirmation:
                    // Save preference and schedule notifications
                Task {
                    let pref = NotificationPreference(
                        isEnabled: true,
                        userType: selectedUserType,
                        identifier: selectedSection,
                        subIdentifier: selectedVariant
                    )
                    
                    notificationManager.savePreference(pref)
                    
                    let success = await notificationManager.scheduleNotifications(routines: routines)
                    
                    if success {
                        dismiss()
                    } else {
                        errorMessage = "Failed to schedule notifications. Please check your settings."
                        showError = true
                    }
                }
        }
    }
    
    private func goBack() {
        switch currentStep {
            case .input:
                currentStep = .userType
            case .variant:
                currentStep = .input
            case .confirmation:
                if selectedUserType == .student && !sectionVariants.isEmpty {
                    currentStep = .variant
                } else {
                    currentStep = .input
                }
            default:
                break
        }
    }
}
