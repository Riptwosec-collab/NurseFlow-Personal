import SwiftUI

@main
struct NurseFlowApp: App {
    @StateObject private var store = ShiftStore()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
                .tint(Palette.blue)
        }
    }
}
