import SwiftUI

extension View {
    /// Adds a subtle rounded border/background suitable for TextFields
    func bordered(cornerRadius: CGFloat = 10, padding: CGFloat = 8, backgroundColor: Color = Color(.secondarySystemBackground), strokeColor: Color = Color(.separator)) -> some View {
        self
            .padding(padding)
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(strokeColor.opacity(0.7), lineWidth: 1))
    }
}
