import SwiftUI

struct DishDetailView: View {
    var dish: Dish
    @State private var editTags = false
    @State private var tags: [String]
    
    init(dish: Dish) {
        self.dish = dish
        _tags = State(initialValue: dish.tags)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Rectangle()
                    .fill(LinearGradient(colors: [Color.brandGreen.opacity(0.28), Color.brandGreen.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .bottomLeading) {
                        Text(dish.displayPrice).padding(8).background(.ultraThinMaterial, in: Capsule()).padding()
                    }
                
                Text(dish.title).font(.title.bold())
                HStack { RatingView(rating: dish.cookRating ?? 0); Text("by \(dish.cookName)").foregroundStyle(.secondary) }
                
                Text(dish.description)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients").font(.headline)
                    Text(dish.ingredients.joined(separator: ", ")).foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("AI Tags").font(.headline)
                        Spacer()
                        Button(editTags ? "Done" : "Edit") { editTags.toggle() }
                    }
                    if editTags {
                        EditableTagsView(tags: $tags)
                    } else {
                        TagChipsView(tags: tags)
                    }
                }
                
                Button {
                    // Open booking flow handled by parent view via sheet, or here could use environment to trigger
                } label: {
                    Text("Book Meal")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.brandGreen))
                        .foregroundStyle(.white)
                }
            }
            .padding()
        }
        .navigationTitle("Dish")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EditableTagsView: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TagChipsView(tags: tags)
            HStack {
                TextField("Add tag", text: $newTag)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    let t = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    tags.append(t)
                    newTag = ""
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    NavigationStack { DishDetailView(dish: MockData.dishes[0]) }
}
