//
//  ExistingPreferenceView.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 15/10/25.
//

import SwiftUI

    // MARK: - Existing Preference View
struct ExistingPreferenceView: View {
    let preference: NotificationPreference?
    let onKeep: () -> Void
    let onChange: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
                // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.teal)
            }
            .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text("Notifications Active")
                    .font(.title.bold())
                
                Text("You're already receiving class notifications")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
                // Current Settings Card
            if let pref = preference {
                VStack(spacing: 16) {
                    Text("Current Settings")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        SettingRow(
                            icon: pref.userType == .student ? "graduationcap.fill" : "person.crop.rectangle.stack.fill",
                            label: "Type",
                            value: pref.userType == .student ? "Student" : "Teacher"
                        )
                        
                        Divider()
                        
                        SettingRow(
                            icon: "tag.fill",
                            label: pref.userType == .student ? "Section" : "Teacher",
                            value: pref.identifier
                        )
                        
                        if let variant = pref.subIdentifier {
                            Divider()
                            
                            SettingRow(
                                icon: "checkmark.circle.fill",
                                label: "Variant",
                                value: variant
                            )
                        }
                        
                        Divider()
                        
                        SettingRow(
                            icon: "clock.fill",
                            label: "Timing",
                            value: "15 min before class"
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
            
            Spacer()
            
                // Action Buttons
            VStack(spacing: 12) {
                Button(action: onKeep) {
                    Text("Keep Current Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                
                Button(action: onChange) {
                    Text("Change Settings")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.bottom)
            .padding(.horizontal, 8)
        }
        .padding(.horizontal)
    }
}

