//
//  OverFlowingText.swift
//  DiuRoutine
//
//  Created by Hafizur Rahman on 1/10/25.
//

import SwiftUI

struct OverFlowingText: View {
    let text: String
    @State private var isOverflowing = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding([.top, .bottom], 6)
                    .lineLimit(1)
                    .brightness(-0.2)
                    .background(
                        GeometryReader { textGeo in
                            Color.clear
                                .onAppear {
                                    if textGeo.size.width > geo.size.width {
                                        isOverflowing = true
                                    }
                                }
                        }
                    )
            }
            .disabled(!isOverflowing)
        }
        .frame(height: 36)
    }
}
