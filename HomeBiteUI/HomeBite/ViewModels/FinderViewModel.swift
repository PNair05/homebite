import Foundation
import MapKit
import Combine

@MainActor
final class FinderViewModel: ObservableObject {
    @Published var dishes: [Dish] = []
    @Published var searchText: String = ""
    @Published var selectedCuisines: Set<String> = []
    @Published var selectedDietary: Set<String> = []
    @Published var proximityKm: Double = 5
    @Published var showMap: Bool = true
    @Published var isCookMode: Bool = false
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 30.6133793, longitude: -96.3436677), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    
    func loadMock() {
        dishes = MockData.dishes
    }
    
    var filteredDishes: [Dish] {
        dishes.filter { dish in
            var ok = true
            if !searchText.isEmpty {
                ok = ok && (dish.title.localizedCaseInsensitiveContains(searchText) || dish.description.localizedCaseInsensitiveContains(searchText))
            }
            if !selectedCuisines.isEmpty { ok = ok && selectedCuisines.contains(dish.cuisine) }
            if !selectedDietary.isEmpty { ok = ok && !selectedDietary.isDisjoint(with: Set(dish.dietary)) }
            return ok
        }
    }
}
