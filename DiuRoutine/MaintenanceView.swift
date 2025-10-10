import SwiftUI
import Lottie

struct MaintenanceView: View {
    var body: some View {
        VStack(spacing: 16) {            
            LottieHelperView(fileName: "error.json", contentMode: .scaleAspectFit, playLoopMode: .loop, speed: 1).frame(maxHeight: 300)
            
            Text("Under Maintenance")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary.opacity(0.85))
            
            Text("The app is currently undergoing maintenance. Please check back later.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary.opacity(0.85))
                .padding()
        }
        .padding()
    }
}

#Preview {
    MaintenanceView()
}
