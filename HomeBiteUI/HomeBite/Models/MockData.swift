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
        ),
        Dish(
            title: "Street Tacos",
            description: "Soft corn tortillas with marinated chicken and salsa verde.",
            ingredients: ["chicken","cilantro","onion","tortilla"],
            price: 7.5,
            barter: false,
            photoURL: nil,
            tags: ["mexican","savory"],
            cuisine: "Mexican",
            dietary: [],
            distanceMeters: 500,
            cookId: UUID(),
            cookName: "Carlos M.",
            cookRating: 4.7,
            coordinate: CLLocationCoordinate2D(latitude: 30.6146, longitude: -96.3446)
        ),
        Dish(
            title: "Veggie Dumplings",
            description: "Steamed dumplings with soy-ginger dipping sauce.",
            ingredients: ["cabbage","mushroom","ginger"],
            price: 6.0,
            barter: false,
            photoURL: nil,
            tags: ["chinese","veg"],
            cuisine: "Chinese",
            dietary: ["Vegetarian"],
            distanceMeters: 610,
            cookId: UUID(),
            cookName: "Liang Z.",
            cookRating: 4.5,
            coordinate: CLLocationCoordinate2D(latitude: 30.6129, longitude: -96.3427)
        ),
        Dish(
            title: "BBQ Brisket Bowl",
            description: "Slow-smoked brisket over rice with pickles.",
            ingredients: ["beef","rice","pickles","sauce"],
            price: 11.0,
            barter: false,
            photoURL: nil,
            tags: ["bbq","texas"],
            cuisine: "American",
            dietary: [],
            distanceMeters: 920,
            cookId: UUID(),
            cookName: "Riley T.",
            cookRating: 4.4,
            coordinate: CLLocationCoordinate2D(latitude: 30.6152, longitude: -96.3460)
        ),
        Dish(
            title: "Falafel Wrap",
            description: "Crispy falafel with tahini and veggies.",
            ingredients: ["chickpeas","tahini","lettuce","tomato"],
            price: 7.0,
            barter: false,
            photoURL: nil,
            tags: ["mediterranean","vegan"],
            cuisine: "Mediterranean",
            dietary: ["Vegan"],
            distanceMeters: 740,
            cookId: UUID(),
            cookName: "Nadia S.",
            cookRating: 4.6,
            coordinate: CLLocationCoordinate2D(latitude: 30.6131, longitude: -96.3472)
        ),
        Dish(
            title: "Sushi Bento",
            description: "Assorted veggie rolls with miso soup.",
            ingredients: ["rice","nori","avocado","cucumber"],
            price: 10.0,
            barter: false,
            photoURL: nil,
            tags: ["japanese","light"],
            cuisine: "Japanese",
            dietary: ["Vegetarian"],
            distanceMeters: 1050,
            cookId: UUID(),
            cookName: "Kenji A.",
            cookRating: 4.3,
            coordinate: CLLocationCoordinate2D(latitude: 30.6109, longitude: -96.3439)
        ),
        Dish(
            title: "Shakshuka",
            description: "Eggs poached in spiced tomato pepper sauce.",
            ingredients: ["tomato","egg","pepper","herbs"],
            price: 8.0,
            barter: false,
            photoURL: nil,
            tags: ["brunch","israeli"],
            cuisine: "Middle Eastern",
            dietary: [],
            distanceMeters: 430,
            cookId: UUID(),
            cookName: "Oren L.",
            cookRating: 4.2,
            coordinate: CLLocationCoordinate2D(latitude: 30.6142, longitude: -96.3420)
        )
    ]
    
    static let ratings: [Rating] = [
        Rating(raterId: UUID(), rateeId: UUID(), stars: 5, comment: "Delicious and on time!"),
        Rating(raterId: UUID(), rateeId: UUID(), stars: 4, comment: "Tasty, a bit spicy."),
        Rating(raterId: UUID(), rateeId: UUID(), stars: 5, comment: "Would order again."),
        Rating(raterId: UUID(), rateeId: UUID(), stars: 3, comment: "Good, portion was small."),
        Rating(raterId: UUID(), rateeId: UUID(), stars: 4, comment: "Great value for money.")
    ]
    
    static let orders: [Order] = [
        Order(dishId: dishes[0].id, buyerId: user.id, sellerId: dishes[0].cookId, scheduledAt: Date().addingTimeInterval(3600*4), status: .confirmed, totalPrice: 9.0),
        Order(dishId: dishes[1].id, buyerId: user.id, sellerId: dishes[1].cookId, scheduledAt: Date().addingTimeInterval(-3600*48), status: .completed, totalPrice: 8.5),
        Order(dishId: dishes[2].id, buyerId: user.id, sellerId: dishes[2].cookId, scheduledAt: Date().addingTimeInterval(3600*24), status: .pending, totalPrice: 0.0),
        Order(dishId: dishes[3].id, buyerId: user.id, sellerId: dishes[3].cookId, scheduledAt: Date().addingTimeInterval(3600*2), status: .confirmed, totalPrice: 7.5),
        Order(dishId: dishes[4].id, buyerId: user.id, sellerId: dishes[4].cookId, scheduledAt: Date().addingTimeInterval(-3600*5), status: .completed, totalPrice: 11.0)
    ]
}
