import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @StateObject private var vm = AnxietyCalculatorViewModel()

    var body: some View {
        if onboardingComplete {
            MainAppView()
                .environmentObject(vm)
        } else {
            OnboardingFlow(completed: $onboardingComplete)
                .environmentObject(vm)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AnxietyCalculatorViewModel())
}
