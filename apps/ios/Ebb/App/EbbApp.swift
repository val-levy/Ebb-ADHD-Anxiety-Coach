import SwiftUI

/// App entry point. Owns the single `ResetStore` and hands it to the view tree.
@main
struct EbbApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = ResetStore(service: SupabaseService.shared)
    @StateObject private var nudges = NudgeStore(service: SupabaseService.shared)
    @StateObject private var session = SessionStore()
    @StateObject private var dumps = BrainDumpStore(service: SupabaseService.shared)
    @StateObject private var calm = CalmStore(service: SupabaseService.shared)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(nudges)
                .environmentObject(calm)
                .environmentObject(session)
                .environmentObject(dumps)
                .font(ClayFont.body)   // handwritten clay type by default; styled text uses ClayFont.*
                .task { await session.start(); await store.load(); await dumps.load() }
                .onChange(of: session.profile?.id) { Task { await dumps.load() } }  // sign in / out / delete swaps the note
                #if DEBUG
                .onAppear { Tip.selfCheck(); PanicGate.selfCheck(); Username.selfCheck() }
                #endif
        }
    }
}
