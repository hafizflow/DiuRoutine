import SwiftUI

struct ThemeChangeView: View {
    var scheme: ColorScheme
    @AppStorage("userTheme") private var userTheme: Theme = .dark
        // For Sliding Effect
    @Namespace private var animation
    @State private var circleOffset: CGSize
    @Environment(\.colorScheme) var colorScheme
    init(scheme: ColorScheme) {
        self.scheme = scheme
        let isDark = scheme == .dark
        self._circleOffset = .init(initialValue: CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Circle()
                .fill(userTheme.color(scheme).gradient)
                .frame(width: 150, height: 150)
                .mask {
                    Rectangle()
                        .overlay {
                            Circle()
                                .offset(circleOffset)
                                .blendMode(.destinationOut)
                        }
                }
            
            Text("Choose a Style")
                .font(.title2.bold())
                .padding(.top, 25)
            
            Text("Shine bright or stay mellow.\nYour theme, your vibe.")
                .multilineTextAlignment(.center)
            
                // Custom Segmented Picker
            HStack(spacing: 0) {
                ForEach(Theme.allCases, id: \.rawValue) { theme in
                    Text(theme.rawValue)
                        .padding(.vertical, 10)
                        .frame(width: 100)
                        .background {
                            ZStack {
                                if userTheme == theme {
                                    Capsule()
                                        .fill(colorScheme == .light ? .gray.opacity(0.1) : .secondary)
                                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                }
                            }
                            .animation(.snappy, value: userTheme)
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            userTheme = theme
                        }
                }
            }
            .padding(3)
            .background(.primary.opacity(0.06), in: .capsule)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 410)
        .background(.themeBG)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .padding(.top, 40)
        .environment(\.colorScheme, scheme)
        .onChange(of: scheme, initial: false) { _, newValue in
            let isDark = newValue == .dark
            withAnimation(.bouncy) {
                circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
            }
        }
    }
}


#Preview {
    ThemeChangeView(scheme: .light)
}



enum Theme: String, CaseIterable {
    case systemDefault = "Default"
    case light = "Light"
    case dark = "Dark"
    
    func color(_ scheme: ColorScheme) -> Color {
        switch self {
            case .systemDefault:
                return scheme == .dark ? .moon : .sun
            case .light:
                return .sun
            case .dark:
                return .moon
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
            case .systemDefault:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }
}
