import SwiftUI

/// "What helped most?" One tap, optional. The answer reorders the panic session next time.
struct HelpedPickerView: View {
    let techniques: [CalmTechnique]
    let onPick: (CalmTechnique?) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("You got through it.").font(ClayFont.title.bold())
            Text("What helped most?").opacity(0.85)
            ForEach(techniques) { technique in
                Button { onPick(technique) } label: {
                    Label(technique.title, systemImage: technique.symbol)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .clay(.white.opacity(0.25), radius: 18)
                }
            }
            Button("Skip") { onPick(nil) }.padding(.top, 8).opacity(0.8)
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(24)
    }
}
