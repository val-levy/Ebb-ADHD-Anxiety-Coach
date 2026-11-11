import Foundation

/// Brain dump text: kept locally for offline, synced to Supabase (debounced) when signed in.
@MainActor
final class NoteStore: ObservableObject {
    @Published var text: String {
        didSet { UserDefaults.standard.set(text, forKey: "dump"); scheduleSave() }
    }
    private let service: SupabaseService
    private var saveTask: Task<Void, Never>?
    private var loading = false

    init(service: SupabaseService) {
        self.service = service
        text = UserDefaults.standard.string(forKey: "dump") ?? ""
    }

    /// Pulls the server copy; if there is none yet, the local text gets uploaded.
    func load() async {
        guard let note = try? await service.note() else { return scheduleSave() }
        loading = true; text = note.body; loading = false
    }

    private func scheduleSave() {
        guard !loading else { return }
        saveTask?.cancel()
        saveTask = Task { [text, service] in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            try? await service.save(Note(body: text))  // ponytail: silent failure; next edit retries
        }
    }
}
