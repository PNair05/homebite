import SwiftUI

struct CampusBitesRootView: View {
    @StateObject private var session = SessionViewModel()
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            Group {
                switch session.route {
                case .onboarding:
                    OnboardingView()
                        .environmentObject(session)
                case .roleSelection:
                    RoleSelectionView()
                        .environmentObject(session)
                case .main:
                    MainTabView()
                        .environmentObject(session)
                }
            }
            .accentColor(.brandGreen)
            .animation(.easeInOut, value: session.route)
        }
    }
}

#Preview {
    CampusBitesRootView()
}
