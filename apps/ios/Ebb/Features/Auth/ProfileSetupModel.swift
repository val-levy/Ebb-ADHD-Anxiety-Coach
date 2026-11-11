import Foundation
import Supabase

/// State and saving for the "pick a username" sheet.
@MainActor
final class ProfileSetupModel: ObservableObject {
    enum Availability: Equatable { case unknown, checking, available, taken, invalid }

    @Published var username = "" { didSet { if username != oldValue { scheduleCheck() } } }
    @Published var displayName = ""
    @Published var animal: AvatarAnimal = .panda
    @Published var availability: Availability = .unknown
    @Published var error: String?
    @Published var isSaving = false

    private let session: SessionStore
    private var checkTask: Task<Void, Never>?

    init(session: SessionStore, appleName: String? = nil) {
        self.session = session
        let d = UserDefaults.standard
        displayName = d.string(forKey: "profileName").flatMap { $0.isEmpty ? nil : $0 } ?? appleName ?? ""
        animal = d.string(forKey: "profileAnimal").flatMap(AvatarAnimal.init(rawValue:)) ?? .panda
    }

    var canSave: Bool {
        availability == .available && !displayName.trimmingCharacters(in: .whitespaces).isEmpty
            && displayName.count <= 40 && !isSaving
    }

    private func scheduleCheck() {
        checkTask?.cancel()
        let name = Username.normalize(username)
        guard Username.isValid(name) else { availability = name.isEmpty ? .unknown : .invalid; return }
        availability = .checking
        checkTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            let free = (try? await session.auth.isAvailable(username: name)) ?? false
            if !Task.isCancelled { availability = free ? .available : .taken }
        }
    }

    func save() async -> Bool {
        guard canSave, let id = session.auth.userId else { return false }
        isSaving = true; defer { isSaving = false }
        let p = Profile(id: id, username: Username.normalize(username),
                        displayName: displayName.trimmingCharacters(in: .whitespaces), bio: nil, animal: animal)
        do {
            try await session.auth.createProfile(p)
            session.profile = p
            ["profileName", "profileBio"].forEach(UserDefaults.standard.removeObject(forKey:))
            UserDefaults.standard.set(p.animal.rawValue, forKey: "profileAnimal") // mascot reads this
            return true
        } catch let e as PostgrestError where e.code == "23505" {
            availability = .taken; error = "That name was just taken"
        } catch {
            self.error = "Couldn't save. Check your connection and try again."
        }
        return false
    }
}
