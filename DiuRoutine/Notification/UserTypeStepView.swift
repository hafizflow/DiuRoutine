//
//  UserTypeStepView.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 15/10/25.
//

import SwiftUI

    // MARK: - Step Views
struct UserTypeStepView: View {
    @Binding var selectedUserType: NotificationPreference.UserType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Who are you?")
                    .font(.title2.bold())
                Text("Select your role to get personalized notifications")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                SelectionCard(
                    icon: "graduationcap.fill",
                    title: "Student",
                    subtitle: "Get notified about your classes",
                    isSelected: selectedUserType == .student
                ) {
                    selectedUserType = .student
                }
                
                SelectionCard(
                    icon: "person.crop.rectangle.stack.fill",
                    title: "Teacher",
                    subtitle: "Get notified about your teaching schedule",
                    isSelected: selectedUserType == .teacher
                ) {
                    selectedUserType = .teacher
                }
            }
        }
    }
}


