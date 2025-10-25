import Foundation
import CoreLocation

enum MockData {
    static let user = User(name: "Ava Lee", email: "ava@uni.edu", university: "Campus U", photoURL: nil, roles: [.customer, .cook, .seller], dietaryRestrictions: ["Vegetarian"], cuisinePreferences: ["Thai", "Italian"], rating: 4.8)
    
    static let dishes: [Dish] = [
        // Center of map is around College Station, TX (30.61338, -96.34367).
        // Place mock dishes within ~0.5–1.0 km of that point for a nice clustered map.
        Dish(
            title: "Spicy Basil Tofu",
            description: "Homestyle Thai basil tofu with jasmine rice.",
            ingredients: ["tofu","basil","garlic","chili"],
            price: 9.0,
            barter: false,
            photoURL: nil,
            tags: ["spicy","thai","veg"],
            cuisine: "Thai",
            dietary: ["Vegetarian"],
            distanceMeters: 320,
            cookId: UUID(),
            cookName: "Ava Lee",
            cookRating: 4.8,
            coordinate: CLLocationCoordinate2D(latitude: 30.6140, longitude: -96.3430)
        ),
        Dish(
            title: "Pasta al Pomodoro",
            description: "Classic pasta with bright tomato sauce.",
            ingredients: ["tomato","pasta","basil","parmesan"],
            price: 8.5,
            barter: false,
            photoURL: nil,
            tags: ["italian"],
            cuisine: "Italian",
            dietary: ["Vegetarian"],
            distanceMeters: 680,
            cookId: UUID(),
            cookName: "M. Rossi",
            cookRating: 4.6,
            coordinate: CLLocationCoordinate2D(latitude: 30.6125, longitude: -96.3450)
        ),
        Dish(
            title: "Barter Curry",
            description: "Help chop and share a cozy curry.",
            ingredients: ["potato","carrot","curry paste"],
            price: nil,
            barter: true,
            photoURL: nil,
            tags: ["share","homestyle"],
            cuisine: "Indian",
            dietary: ["Vegan"],
            distanceMeters: 850,
            cookId: UUID(),
            cookName: "J. Patel",
            cookRating: 4.9,
            coordinate: CLLocationCoordinate2D(latitude: 30.6118, longitude: -96.3415)
        )
    ]
    
    static let ratings: [Rating] = [
        Rating(raterId: UUID(), rateeId: UUID(), stars: 5, comment: "Delicious and on time!"),
        Rating(raterId: UUID(), rateeId: UUID(), stars: 4, comment: "Tasty, a bit spicy.")
    ]
    
    static let orders: [Order] = [
        Order(dishId: dishes[0].id, buyerId: user.id, sellerId: dishes[0].cookId, scheduledAt: Date().addingTimeInterval(3600*4), status: .confirmed, totalPrice: 9.0),
        Order(dishId: dishes[1].id, buyerId: user.id, sellerId: dishes[1].cookId, scheduledAt: Date().addingTimeInterval(-3600*48), status: .completed, totalPrice: 8.5)
    ]
}
