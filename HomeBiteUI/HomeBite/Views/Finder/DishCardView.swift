import SwiftUI

struct DishCardView: View {
    var dish: Dish
    var scheduleAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(LinearGradient(colors: [Color.brandGreen.opacity(0.28), Color.brandGreen.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                .frame(height: 140)
                .overlay(alignment: .topTrailing) {
                    Text(dish.displayPrice)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(dish.title).font(.headline)
            HStack(spacing: 8) {
                RatingView(rating: dish.cookRating ?? 0)
                if let dist = dish.distanceMeters { Text(String(format: "%.1f km", dist/1000)) .font(.caption).foregroundStyle(.secondary) }
                Spacer()
                Button(action: scheduleAction) {
                    Label("Schedule", systemImage: "calendar.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(.brandGreen)
            }
            TagChipsView(tags: dish.tags)
        }
        .padding()
        .glassContainer(cornerRadius: 16)
    }
}
