import Foundation
import Combine

@MainActor
final class KitchenViewModel: ObservableObject {
    @Published var myDishes: [Dish] = []
    @Published var newDish = Dish(title: "", description: "", ingredients: [], price: nil, barter: false, photoURL: nil, tags: [], cuisine: "", dietary: [], distanceMeters: nil, cookId: UUID(), cookName: "", cookRating: nil, coordinate: nil)
    
    func loadMock(user: User?) {
        myDishes = MockData.dishes.filter { _ in true }
        if let u = user {
            newDish.cookId = u.id
            newDish.cookName = u.name
        }
    }
    
    func saveNewDish() async throws {
        let created = try await APIService.shared.createDish(
            title: newDish.title,
            description: newDish.description,
            price: newDish.price ?? 0,
            availableQty: nil,
            prepTimeMinutes: nil,
            pickupLocation: nil,
            campusId: nil,
            imageURLs: newDish.photoURL.map { [$0.absoluteString] } ?? [],
            tags: newDish.tags
        )
        let mapped = Dish(
            id: created.id,
            title: created.title,
            description: created.description ?? "",
            ingredients: [],
            price: created.price,
            barter: false,
            photoURL: created.images.first.flatMap { URL(string: $0) },
            tags: created.tags,
            cuisine: "",
            dietary: [],
            distanceMeters: nil,
            cookId: created.cook_id,
            cookName: "",
            cookRating: nil,
            coordinate: nil
        )
        myDishes.append(mapped)
        newDish = Dish(title: "", description: "", ingredients: [], price: nil, barter: false, photoURL: nil, tags: [], cuisine: "", dietary: [], distanceMeters: nil, cookId: newDish.cookId, cookName: newDish.cookName, cookRating: nil, coordinate: nil)
    }
}
