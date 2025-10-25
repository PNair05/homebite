import Foundation
import Combine

enum AppRoute {
    case onboarding
    case roleSelection
    case main
}

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var selectedRoles: [UserRole] = []
    @Published var route: AppRoute = .onboarding
    
    // Onboarding fields
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var university: String = ""
    @Published var dietary: [String] = []
    @Published var cuisines: [String] = []
    
    func loginOrSignup() async {
        // Try login; if not registered, fallback to signup
        do {
            _ = try await APIService.shared.login(email: email, password: password)
        } catch {
            _ = try? await APIService.shared.signup(fullName: name, email: email, password: password, role: "consumer", campusId: nil)
        }
        // Minimal mapping to local user model for now
        let newUser = User(name: name.isEmpty ? "Student" : name,
                           email: email,
                           university: university.isEmpty ? "Your University" : university,
                           photoURL: nil,
                           roles: [],
                           dietaryRestrictions: dietary,
                           cuisinePreferences: cuisines,
                           rating: 4.7)
        self.user = newUser
        self.isAuthenticated = true
        self.route = .roleSelection
    }
    
    func setRoles(_ roles: [UserRole]) {
        selectedRoles = roles
        guard var u = user else { return }
        u.roles = roles
        user = u
        route = .main
    }
    
    func logout() {
        user = nil
        isAuthenticated = false
        selectedRoles = []
        route = .onboarding
        name = ""; email = ""; password = ""; university = ""
        dietary = []; cuisines = []
    }
}
