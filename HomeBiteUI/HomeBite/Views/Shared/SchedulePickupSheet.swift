import SwiftUI

struct SchedulePickupSheet: View {
    @Binding var date: Date
    var onConfirm: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("Pickup time", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .padding()
                Button(action: onConfirm) {
                    Text("Confirm Pickup")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.brandGreen))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Schedule Pickup")
            .toolbar { ToolbarItem(placement: .cancellationAction) { EmptyView() } }
        }
    }
}
