import SwiftUI

struct MyKitchenView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = KitchenViewModel()
    @State private var showAdd = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.myDishes) { dish in
                    NavigationLink(value: dish.id) {
                        VStack(alignment: .leading) {
                            Text(dish.title).font(.headline)
                            Text(dish.displayPrice).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Kitchen")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: { Image(systemName: "plus").foregroundStyle(Color.brandGreen) }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddDishView(dish: $vm.newDish) {
                    Task { try? await vm.saveNewDish(); showAdd = false }
                }
                .presentationDetents([.large])
                .environmentObject(session)
            }
            .onAppear { vm.loadMock(user: session.user) }
        }
    }
}

#Preview {
    MyKitchenView().environmentObject(SessionViewModel())
}
