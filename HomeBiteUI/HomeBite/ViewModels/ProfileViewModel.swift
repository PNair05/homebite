import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var ratings: [Rating] = []
    
    func loadMock(user: User?) {
        ratings = MockData.ratings
    }
}
