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
}
