import Foundation
import CoreLocation

struct Dish: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var ingredients: [String]
    var price: Double?
    var barter: Bool = false // "Cook for share" option
    var photoURL: URL?
    var tags: [String] = []
    var cuisine: String
    var dietary: [String] = []
    var distanceMeters: Double? // calculated client-side for mock
    var cookId: UUID
    var cookName: String
    var cookRating: Double?
    var coordinate: CLLocationCoordinate2D?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, ingredients, price, barter, photoURL, tags, cuisine, dietary, distanceMeters, cookId, cookName, cookRating
        case latitude
        case longitude
    }
    
    init(id: UUID = UUID(), title: String, description: String, ingredients: [String], price: Double?, barter: Bool = false, photoURL: URL?, tags: [String] = [], cuisine: String, dietary: [String] = [], distanceMeters: Double? = nil, cookId: UUID, cookName: String, cookRating: Double? = nil, coordinate: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.price = price
        self.barter = barter
        self.photoURL = photoURL
        self.tags = tags
        self.cuisine = cuisine
        self.dietary = dietary
        self.distanceMeters = distanceMeters
        self.cookId = cookId
        self.cookName = cookName
        self.cookRating = cookRating
        self.coordinate = coordinate
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try c.decode(String.self, forKey: .title)
        description = try c.decode(String.self, forKey: .description)
        ingredients = try c.decodeIfPresent([String].self, forKey: .ingredients) ?? []
        price = try c.decodeIfPresent(Double.self, forKey: .price)
        barter = try c.decodeIfPresent(Bool.self, forKey: .barter) ?? false
        photoURL = try c.decodeIfPresent(URL.self, forKey: .photoURL)
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        cuisine = try c.decodeIfPresent(String.self, forKey: .cuisine) ?? ""
        dietary = try c.decodeIfPresent([String].self, forKey: .dietary) ?? []
        distanceMeters = try c.decodeIfPresent(Double.self, forKey: .distanceMeters)
        cookId = try c.decodeIfPresent(UUID.self, forKey: .cookId) ?? UUID()
        cookName = try c.decodeIfPresent(String.self, forKey: .cookName) ?? ""
        cookRating = try c.decodeIfPresent(Double.self, forKey: .cookRating)
        if let lat = try c.decodeIfPresent(Double.self, forKey: .latitude),
           let lon = try c.decodeIfPresent(Double.self, forKey: .longitude) {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            coordinate = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(description, forKey: .description)
        try c.encode(ingredients, forKey: .ingredients)
        try c.encodeIfPresent(price, forKey: .price)
        try c.encode(barter, forKey: .barter)
        try c.encodeIfPresent(photoURL, forKey: .photoURL)
        try c.encode(tags, forKey: .tags)
        try c.encode(cuisine, forKey: .cuisine)
        try c.encode(dietary, forKey: .dietary)
        try c.encodeIfPresent(distanceMeters, forKey: .distanceMeters)
        try c.encode(cookId, forKey: .cookId)
        try c.encode(cookName, forKey: .cookName)
        try c.encodeIfPresent(cookRating, forKey: .cookRating)
        if let coord = coordinate {
            try c.encode(coord.latitude, forKey: .latitude)
            try c.encode(coord.longitude, forKey: .longitude)
        }
    }
}

extension Dish {
    var displayPrice: String {
        if let price { return String(format: "$%.2f", price) }
        return barter ? "Cook for share" : "—"
    }
}

extension Dish {
    static func == (lhs: Dish, rhs: Dish) -> Bool {
        // Consider dishes equal if they share the same id
        lhs.id == rhs.id
    }
}
