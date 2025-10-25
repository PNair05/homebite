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
        // Placeholder API call
        try await Task.sleep(nanoseconds: 400_000_000)
        myDishes.append(newDish)
        newDish = Dish(title: "", description: "", ingredients: [], price: nil, barter: false, photoURL: nil, tags: [], cuisine: "", dietary: [], distanceMeters: nil, cookId: newDish.cookId, cookName: newDish.cookName, cookRating: nil, coordinate: nil)
    }
}
