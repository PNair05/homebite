import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: SessionViewModel
    
    var body: some View {
        TabView {
            FinderView()
                .tabItem { Label("Finder", systemImage: "map") }
            
            OrdersScheduleView()
                .tabItem { Label("Schedule", systemImage: "calendar") }
            
            if session.selectedRoles.contains(.cook) || session.selectedRoles.contains(.seller) {
                MyKitchenView()
                    .tabItem { Label("My Kitchen", systemImage: "fork.knife.circle") }
            }
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    .tint(.brandGreen)
    }
}

#Preview {
    let s = SessionViewModel()
    s.selectedRoles = [.customer, .cook, .seller]
    return MainTabView().environmentObject(s)
}
