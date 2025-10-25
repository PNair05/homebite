import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case customer = "Customer"
    case cook = "Cook"
    case seller = "Seller"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .customer: return "fork.knife"
        case .cook: return "frying.pan"
        case .seller: return "bag"
        }
    }
}

struct User: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var university: String
    var photoURL: URL?
    var roles: [UserRole] = []
    var dietaryRestrictions: [String] = []
    var cuisinePreferences: [String] = []
    var rating: Double? = nil
}
