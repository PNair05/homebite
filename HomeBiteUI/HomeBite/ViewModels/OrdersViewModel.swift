import Foundation
import Combine

@MainActor
final class OrdersViewModel: ObservableObject {
    @Published var upcoming: [Order] = []
    @Published var past: [Order] = []
    @Published var cookBookings: [Order] = []
    
    func loadMock(user: User?) {
        let all = MockData.orders
        upcoming = all.filter { $0.scheduledAt > Date() }
        past = all.filter { $0.scheduledAt <= Date() }
        cookBookings = upcoming.filter { _ in false }
    }

    func loadFromAPI() async {
        do {
            let apiOrders = try await APIService.shared.fetchOrders(as: "buyer")
            let mapped: [Order] = apiOrders.map { o in
                Order(
                    id: o.id,
                    dishId: o.items.first?.dish_id ?? UUID(),
                    buyerId: o.buyer_id,
                    sellerId: o.cook_id ?? UUID(),
                    scheduledAt: ISO8601DateFormatter().date(from: o.scheduled_pickup ?? "") ?? Date(),
                    status: Order.Status(rawValue: o.status) ?? .pending,
                    totalPrice: o.total
                )
            }
            upcoming = mapped.filter { $0.scheduledAt > Date() }
            past = mapped.filter { $0.scheduledAt <= Date() }
        } catch {
            // ignore and keep mock
        }
    }
}
