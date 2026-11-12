import SwiftUI

/// App entry point. Owns the single `ResetStore` and hands it to the view tree.
@main
struct EbbApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = ResetStore(service: SupabaseService.shared)
    @StateObject private var nudges = NudgeStore(service: SupabaseService.shared)
    @StateObject private var session = SessionStore()
    @StateObject private var dumps: BrainDumpStore
    @StateObject private var logs: LogStore
    @StateObject private var chat: ChatStore
    @StateObject private var memory = MemoryStore(service: SupabaseService.shared)
    @StateObject private var chatStyle = ChatStyleStore(service: SupabaseService.shared)
    @StateObject private var calm = CalmStore(service: SupabaseService.shared)

    init() {
        let dumps = BrainDumpStore(service: SupabaseService.shared)
        let logs = LogStore(service: SupabaseService.shared)
        _dumps = StateObject(wrappedValue: dumps)
        _logs = StateObject(wrappedValue: logs)
        _chat = StateObject(wrappedValue: ChatStore(service: SupabaseService.shared) { await dumps.load(); await logs.load() })
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(nudges)
                .environmentObject(calm)
                .environmentObject(session)
                .environmentObject(dumps)
                .environmentObject(logs)
                .environmentObject(chat)
                .environmentObject(memory)
                .environmentObject(chatStyle)
                .labelStyle(ClayLabelStyle())
                .font(ClayFont.body)   // handwritten clay type by default; styled text uses ClayFont.*
                .task { await session.start(); await store.load(); await dumps.load(); await logs.load() }
                .onChange(of: session.profile?.id) { Task { await dumps.load(); await logs.load(); await memory.load(); await chatStyle.load() } }  // sign in / out / delete swaps the note
                #if DEBUG
                .onAppear { Tip.selfCheck(); PanicGate.selfCheck(); Username.selfCheck(); DailyCount.selfCheck(); LogInsights.selfCheck(); ReflectModule.selfCheck(); ReflectDrag.selfCheck(); ScrollControl.selfCheck() }
                #endif
        }
    }
}
