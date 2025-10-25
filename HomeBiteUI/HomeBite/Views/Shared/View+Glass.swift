import SwiftUI

extension View {
    @ViewBuilder
    func glassBackgroundEffect(cornerRadius: CGFloat = 16) -> some View {
        if #available(iOS 15.0, *) {
            self
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            self
                .padding()
                .background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(Color(.secondarySystemBackground)))
        }
    }

    @ViewBuilder
    func glassContainer(cornerRadius: CGFloat = 16, addShadow: Bool = true) -> some View {
        if #available(iOS 15.0, *) {
            self
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .shadow(color: addShadow ? Color.black.opacity(0.06) : .clear, radius: addShadow ? 8 : 0, x: 0, y: addShadow ? 4 : 0)
        } else {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .shadow(color: addShadow ? Color.black.opacity(0.06) : .clear, radius: addShadow ? 8 : 0, x: 0, y: addShadow ? 4 : 0)
        }
    }
}
