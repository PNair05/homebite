import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Avatar placeholder
                    ZStack {
                        Circle().fill(Color.brandGreen.opacity(0.2)).frame(width: 100, height: 100)
                        Image(systemName: "person.fill").font(.system(size: 48)).foregroundStyle(Color.brandGreen)
                    }.padding(.top, 12)
                    
                    Text(session.user?.name ?? "Student").font(.title2.bold())
                    Text(session.user?.university ?? "University").foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(session.selectedRoles, id: \.self) { role in
                            Label(role.rawValue, systemImage: role.systemImage)
                                .font(.caption)
                                .padding(6)
                                .background(Capsule().fill(Color(.secondarySystemBackground)))
                        }
                    }
                    
                    if let r = session.user?.rating { RatingView(rating: r) }
                    
                    Divider().padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ratings Received").font(.headline)
                        ForEach(vm.ratings) { rating in
                            HStack {
                                RatingView(rating: Double(rating.stars))
                                Text(rating.comment ?? "")
                                Spacer()
                                Text(rating.createdAt, style: .date).font(.caption).foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .glassContainer(cornerRadius: 12, addShadow: false)
                        }
                    }
                    
                    HStack {
                        Button("Edit Profile") {}
                            .buttonStyle(.bordered)
                        Spacer()
                        Button("Logout", role: .destructive) { session.logout() }
                            .buttonStyle(.borderedProminent)
                            .tint(.brandGreen)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear { vm.loadMock(user: session.user) }
        }
    }
}

#Preview {
    let s = SessionViewModel(); s.user = MockData.user; s.selectedRoles = [.customer, .cook]
    return ProfileView().environmentObject(s)
}
