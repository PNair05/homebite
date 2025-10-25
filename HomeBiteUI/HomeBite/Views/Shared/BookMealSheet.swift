import SwiftUI

struct BookMealSheet: View {
    var dish: Dish
    @Binding var date: Date
    var onConfirm: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(dish.title).font(.title2.bold())
                Text(dish.description).foregroundStyle(.secondary)
                HStack { Text("When:"); Text(date.formatted(date: .abbreviated, time: .shortened)).bold() }
                Divider()
                HStack {
                    Image(systemName: "creditcard")
                    Text(dish.displayPrice)
                    Spacer()
                }
                .padding()
                .glassContainer(cornerRadius: 12, addShadow: false)
                Button(action: onConfirm) {
                    Text("Pay & Book")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.brandGreen))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Confirm Booking")
        }
    }
}
