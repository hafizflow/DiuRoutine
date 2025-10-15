//
//  ConfirmationStepView.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 15/10/25.
//

import SwiftUI

struct ConfirmationStepView: View {
    let userType: NotificationPreference.UserType
    let identifier: String
    let variant: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm setup")
                    .font(.title2.bold())
                Text("You'll receive notifications 15 minutes before each class")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                InfoRow(label: "Type", value: userType == .student ? "Student" : "Teacher")
                InfoRow(label: userType == .student ? "Section" : "Teacher", value: identifier)
                
                if let variant = variant {
                    InfoRow(label: "Variant", value: variant)
                }
                
                InfoRow(label: "Notification Time", value: "15 minutes before class")
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            
            Button (action: {
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(.orange)
                    Text("Make sure notifications are enabled in Settings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }
}
