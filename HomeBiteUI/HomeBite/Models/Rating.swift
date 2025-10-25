import Foundation

struct Rating: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var raterId: UUID
    var rateeId: UUID
    var stars: Int // 1-5
    var comment: String?
    var createdAt: Date = Date()
}
