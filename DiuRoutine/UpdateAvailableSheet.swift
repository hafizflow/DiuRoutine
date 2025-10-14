import SwiftUI

struct UpdateAvailableSheet: View {
    var appInfo: AppVersionManager.ReturnResult
    var forceUpdate: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(spacing: 15) {
            Image(.appUpdate)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack(spacing: 8) {
                Text("App Update Available")
                    .font(.title.bold())
                
                Text("There is an app update available from\nversion **\(appInfo.currentVersion)** to version **\(appInfo.availableVersion)**!")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 5)

            HStack(spacing: 8) {
                if let appURL = URL(string: appInfo.appURL) {
                    if #available(iOS 26.0, *) {
                        Button {
                            openURL(appURL)
                            if !forceUpdate {
                                dismiss()
                            }
                        } label: {
                            Text("Update App")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.capsule)
                    } else {
                        Button {
                            openURL(appURL)
                            if !forceUpdate {
                                dismiss()
                            }
                        } label: {
                            Text("Update App")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                }
            }
        }
        .fontDesign(.rounded)
        .padding(20)
        .padding(.bottom, isiOS26 ? 10 : 0)
        .presentationDetents([.height(420)])
        .interactiveDismissDisabled(forceUpdate)
        .ignoresSafeArea(.all, edges: isiOS26 ? .all : [])
    }
    
    
    var isiOS26: Bool {
        if #available(iOS 26, *) { return true }
        return false
    }
}
