import SwiftUI
import Lottie

struct LottieHelperView: View {
    var fileName: String = ""
    var contentMode: UIView.ContentMode = .scaleAspectFill
    var playLoopMode: LottieLoopMode = .playOnce
    var speed: CGFloat = 1
    
    var body: some View {
        LottieView(animation: .named(fileName))
            .configure { lottieAnimationView in
                lottieAnimationView.contentMode = contentMode
                lottieAnimationView.shouldRasterizeWhenIdle = true
                lottieAnimationView.animationSpeed = speed
            }
            .playbackMode(.playing(.toProgress(1, loopMode: playLoopMode)))
    }
}


#Preview {
    LottieHelperView(fileName: "sloth.json", contentMode: .scaleAspectFit, playLoopMode: .loop)
}
