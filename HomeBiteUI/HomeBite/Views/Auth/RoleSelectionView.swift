import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var selections: Set<UserRole> = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Choose your roles")
                    .font(.title.bold())
                Text("You can change these later in your profile.")
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(UserRole.allCases) { role in
                        Toggle(isOn: Binding(
                            get: { selections.contains(role) },
                            set: { newVal in
                                if newVal { selections.insert(role) } else { selections.remove(role) }
                            }
                        )) {
                            HStack(spacing: 12) {
                                Image(systemName: role.systemImage)
                                    .frame(width: 28)
                                    .foregroundStyle(Color.brandGreen)
                                Text(role.rawValue)
                                    .font(.headline)
                                Spacer()
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .brandGreen))
                        .padding()
                        .glassContainer(cornerRadius: 16, addShadow: false)
                    }
                }
                .padding(.horizontal)
                
                Button {
                    session.setRoles(Array(selections))
                } label: {
                    Text("Continue")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.brandGreen))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .disabled(selections.isEmpty)
                
                Spacer()
            }
            .padding(.top, 24)
            .onAppear {
                selections = Set(session.selectedRoles)
            }
        }
    }
}

#Preview {
    RoleSelectionView().environmentObject(SessionViewModel())
}
