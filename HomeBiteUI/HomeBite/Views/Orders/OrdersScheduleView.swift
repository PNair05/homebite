import SwiftUI

struct OrdersScheduleView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = OrdersViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if !vm.upcoming.isEmpty {
                    Section("Upcoming") {
                        ForEach(vm.upcoming) { order in OrderRow(order: order) }
                    }
                }
                if !vm.cookBookings.isEmpty {
                    Section("Cook Bookings") {
                        ForEach(vm.cookBookings) { order in OrderRow(order: order) }
                    }
                }
                if !vm.past.isEmpty {
                    Section("Past") {
                        ForEach(vm.past) { order in OrderRow(order: order) }
                    }
                }
            }
            .navigationTitle("Schedule")
            .onAppear { vm.loadMock(user: session.user) }
        }
    }
}

struct OrderRow: View {
    let order: Order
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(order.scheduledAt, style: .date)
                Text(order.scheduledAt, style: .time).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(order.status.rawValue.capitalized).font(.caption).padding(6).background(Capsule().fill(Color(.secondarySystemBackground)))
        }
    }
}

#Preview {
    OrdersScheduleView().environmentObject(SessionViewModel())
}
