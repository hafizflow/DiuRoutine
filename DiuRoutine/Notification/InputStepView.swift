//
//  InputStepView.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 15/10/25.
//

import SwiftUI

struct InputStepView: View {
    let userType: NotificationPreference.UserType
    @Binding var searchText: String
    let allSections: [String]
    let allTeachers: [(name: String, initial: String)]
    
    var filteredSuggestions: [String] {
        if userType == .student {
            return allSections.filter { section in
                searchText.isEmpty || section.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            return allTeachers.filter { teacher in
                searchText.isEmpty ||
                teacher.name.localizedCaseInsensitiveContains(searchText) ||
                teacher.initial.localizedCaseInsensitiveContains(searchText)
            }.map { "\($0.name) (\($0.initial))" }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(userType == .student ? "Enter your section" : "Enter teacher initial")
                    .font(.title2.bold())
                Text(userType == .student ? "e.g., 61_N" : "e.g., MMA")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            TextField(userType == .student ? "Section" : "Initial", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty && !filteredSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Suggestions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredSuggestions.prefix(5), id: \.self) { suggestion in
                                Button {
                                    if userType == .student {
                                        searchText = suggestion
                                    } else {
                                            // Extract initial from "Name (Initial)"
                                        if let initial = suggestion.split(separator: "(").last?.dropLast().trimmingCharacters(in: .whitespaces) {
                                            searchText = String(initial)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(suggestion)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "arrow.up.left")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .contentShape(Rectangle())
                                }
                                
                                if suggestion != filteredSuggestions.prefix(5).last {
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
    }
}
