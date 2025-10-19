//
//  VariantStepView.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 15/10/25.
//

import SwiftUI

struct VariantStepView: View {
    let selectedSection: String
    let variants: [String]
    @Binding var selectedVariant: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Select section variant")
                    .font(.title2.bold())
                Text("Choose your specific section")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(variants.indices, id: \.self) { index in
                    let variant = variants[index]
                    let isSelected = selectedVariant == variant
                    let iconName = "\(index + 1).circle" + (isSelected ? ".fill" : "")
                    
                    SelectionCard(
                        icon: iconName,
                        title: variant,
                        subtitle: "Only \(variant) classes",
                        isSelected: isSelected
                    ) {
                        selectedVariant = variant
                    }
                }
            }
        }
    }
}

