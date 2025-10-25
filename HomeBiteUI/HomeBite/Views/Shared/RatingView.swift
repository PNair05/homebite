import SwiftUI

struct RatingView: View {
    var rating: Double
    var max: Int = 5
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<max, id: \.self) { i in
                Image(systemName: i < Int(round(rating)) ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
            }
            Text(String(format: "%.1f", rating))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
