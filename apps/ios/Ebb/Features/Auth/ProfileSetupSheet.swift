import SwiftUI

/// Pick a username, name and animal after linking Apple. Closing it leaves you not signed in.
struct ProfileSetupSheet: View {
    @StateObject var model: ProfileSetupModel
    @Environment(\.dismiss) private var dismiss
    @State private var picking = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Button { picking = true } label: { AnimalAvatar(animal: model.animal, size: 96) }
                Text("Make your profile").font(ClayFont.title2)
                VStack(alignment: .leading, spacing: 6) {
                    TextField("username", text: $model.username)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .font(ClayFont.headline).padding(14).clay(Theme.tile, radius: 16)
                    Text(statusText).font(ClayFont.footnote).foregroundStyle(statusColor)
                    TextField("Display name", text: $model.displayName)
                        .font(ClayFont.headline).padding(14).clay(Theme.tile, radius: 16)
                }
                if let err = model.error { Text(err).font(ClayFont.footnote).foregroundStyle(Theme.clayOrange) }
                Button {
                    Task { if await model.save() { dismiss() } }
                } label: {
                    Text(model.isSaving ? "Saving…" : "Save").font(ClayFont.headline)
                        .frame(maxWidth: .infinity).padding(14).foregroundStyle(.white)
                        .clay(model.canSave ? Theme.accent : .gray.opacity(0.5), radius: 26)
                }
                .disabled(!model.canSave)
            }
            .padding(24)
        }
        .interactiveDismissDisabled(model.isSaving)
        .sheet(isPresented: $picking) { AvatarPicker(selection: $model.animal) }
    }

    private var statusText: String {
        switch model.availability {
        case .unknown: "3–20 letters, numbers or _"
        case .checking: "Checking…"
        case .available: "Available"
        case .taken: "That name is taken"
        case .invalid: "3–20 letters, numbers or _"
        }
    }

    private var statusColor: Color {
        switch model.availability {
        case .available: Theme.accent
        case .taken: Theme.clayOrange
        default: .secondary
        }
    }
}
