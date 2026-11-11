import SwiftUI

/// App entry point. Owns the single `ResetStore` and hands it to the view tree.
@main
struct EbbApp: App {
    @StateObject private var store = ResetStore(service: SupabaseService.shared)
    @StateObject private var calm = CalmStore(service: SupabaseService.shared)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(calm)
                .font(ClayFont.body)   // handwritten clay type by default; styled text uses ClayFont.*
                .task { await store.load() }
                #if DEBUG
                .onAppear { Tip.selfCheck(); PanicGate.selfCheck() }
                #endif
        }
    }
}
