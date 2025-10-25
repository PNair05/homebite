import SwiftUI
import MapKit

struct FinderView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = FinderViewModel()
    @State private var selectedDish: Dish? = nil
    @State private var scheduleDate = Date()
    @State private var showBook = false
    
    private let cuisineOptions = ["Italian","Thai","Indian","Mexican","Chinese","American"]
    private let dietaryOptions = ["Vegetarian","Vegan","Gluten-Free","Halal","Kosher"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                if vm.isCookMode {
                        HStack(spacing: 8) {
                            Image(systemName: "frying.pan").foregroundStyle(Color.brandGreen)
                            Text("Cook mode: set your spot and availability for today.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.brandGreen.opacity(0.08))
                    }
                
                filterBar
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                if vm.showMap { mapView } else { listView }
            }
            .navigationTitle("Finder")
            .toolbarTitleDisplayMode(.inline)
            .sheet(item: $selectedDish) { dish in
                SchedulePickupSheet(date: $scheduleDate) {
                    showBook = true
                }
                .presentationDetents([.medium])
                .onDisappear { scheduleDate = Date() }
            }
            .sheet(isPresented: $showBook) {
                if let dish = selectedDish {
                    BookMealSheet(dish: dish, date: $scheduleDate) {
                        // Simulate booking confirmation
                        showBook = false
                        selectedDish = nil
                    }
                }
            }
            .onAppear {
                Task { await vm.loadFromAPI() }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Picker("Mode", selection: $vm.isCookMode) {
                Text("Customer").tag(false)
                Text("Cook").tag(true)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)
            Spacer()
            Button {
                withAnimation { vm.showMap.toggle() }
            } label: {
                Label(vm.showMap ? "List" : "Map", systemImage: vm.showMap ? "list.bullet" : "map")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Menu {
                    ForEach(cuisineOptions, id: \.self) { c in
                        Button(action: { toggle(&vm.selectedCuisines, c) }) {
                            Label(c, systemImage: vm.selectedCuisines.contains(c) ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Cuisine", systemImage: "line.3.horizontal.decrease.circle")
                }
                
                Menu {
                    ForEach(dietaryOptions, id: \.self) { d in
                        Button(action: { toggle(&vm.selectedDietary, d) }) {
                            Label(d, systemImage: vm.selectedDietary.contains(d) ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Dietary", systemImage: "leaf")
                }
                
                Menu {
                    Picker("Proximity", selection: $vm.proximityKm) {
                        ForEach([1.0, 2.0, 5.0, 10.0, 20.0], id: \.self) { v in
                            Text("\(Int(v)) km").tag(v)
                        }
                    }
                } label: { Label("\(Int(vm.proximityKm)) km", systemImage: "location") }
                
                TextField("Search dishes", text: $vm.searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 260)
            }
        }
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.filteredDishes) { dish in
                    NavigationLink {
                        DishDetailView(dish: dish)
                    } label: {
                        DishCardView(dish: dish) {
                            selectedDish = dish
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $vm.region, annotationItems: vm.filteredDishes.compactMap { d -> IdentifiedCoordinate? in
            if let c = d.coordinate { return IdentifiedCoordinate(id: d.id, coordinate: c, title: d.title) }
            return nil
        }) { item in
            MapAnnotation(coordinate: item.coordinate) {
                Button {
                    if let dish = vm.dishes.first(where: { $0.id == item.id }) { selectedDish = dish }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill").font(.title).foregroundStyle(Color.brandGreen)
                        Text(item.title).font(.caption).fixedSize()
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func toggle<T: Hashable>(_ set: inout Set<T>, _ item: T) {
        if set.contains(item) { set.remove(item) } else { set.insert(item) }
    }
}

struct IdentifiedCoordinate: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String
}

#Preview {
    FinderView().environmentObject(SessionViewModel())
}
