import SwiftUI

@main
struct VoiceRecorderApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
    }
}
