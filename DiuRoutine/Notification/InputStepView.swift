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
                Text(userType == .student ? "Example: 61_N, 62_D" : "Example: SEA, MZJ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            TextField(userType == .student ? "Section" : "Initial", text: $searchText)
                .padding()
                .frame(height: 45)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )
            
            if !searchText.isEmpty && !filteredSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Suggestions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredSuggestions.prefix(20), id: \.self) { suggestion in
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
                                        Spacer()
                                        Image(systemName: "arrow.up.left")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.primary)
                                    .padding()
                                    .contentShape(Rectangle())
                                }
                                
                                if suggestion != filteredSuggestions.prefix(5).last {
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 8)
    }
}
