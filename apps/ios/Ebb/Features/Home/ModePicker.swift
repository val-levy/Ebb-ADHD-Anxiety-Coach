import SwiftUI

/// A chunky clay toggle: a grainy colored clay blob slides inside a white clay track, under the chosen mode.
struct ModePicker: View {
    @Binding var mode: CalmMode
    @Namespace private var blob

    var body: some View {
        HStack(spacing: 6) {
            ForEach(CalmMode.allCases) { m in
                Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { mode = m } } label: {
                    Label(m.title, systemImage: m.symbol)
                        .font(ClayFont.subheadline.bold())
                        .foregroundStyle(mode == m ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background {
                            if mode == m {
                                Color.clear
                                    .clay(m == .quick ? Theme.clayTeal : Theme.clayLavender, radius: 24)
                                    .overlay { GrainOverlay().clipShape(.rect(cornerRadius: 24, style: .continuous)) }
                                    .matchedGeometryEffect(id: "blob", in: blob)
                            }
                        }
                }
                .accessibilityAddTraits(mode == m ? .isSelected : [])
            }
        }
        .padding(6)
        .clay(radius: 30)
    }
}
