import Foundation

struct Order: Identifiable, Codable, Equatable {
    enum Status: String, Codable, CaseIterable { case pending, confirmed, completed, cancelled }
    var id: UUID = UUID()
    var dishId: UUID
    var buyerId: UUID
    var sellerId: UUID
    var scheduledAt: Date
    var status: Status
    var totalPrice: Double?
}
