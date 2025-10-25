import SwiftUI
import PhotosUI

struct AddDishView: View {
    @EnvironmentObject var session: SessionViewModel
    @Binding var dish: Dish
    var onSave: () -> Void
    
    @State private var priceText: String = ""
    @State private var tagText: String = ""
    @State private var photoPicked: Bool = false // placeholder
    
    private let dietaryOptions = ["Vegetarian","Vegan","Gluten-Free","Halal","Kosher"]

    // Mode selection
    enum Mode: String, CaseIterable, Identifiable { case addDish = "Add Dish", hireChef = "Hire a Chef"; var id: String { rawValue } }
    @State private var mode: Mode = .addDish

    // Hire-a-chef states
    @State private var requestTitle: String = ""
    @State private var hireTags: [String] = []
    @State private var hireTagText: String = ""
    @State private var pantryItems: [String] = []
    @State private var pantryNewItem: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var pantryImages: [UIImage] = []
    @State private var isTagLoading: Bool = false
    @State private var isRecipeLoading: Bool = false
    @State private var recipeResult: (title: String, ingredients: [String], steps: [String])? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { m in Text(m.rawValue).tag(m) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Form {
                    if mode == .addDish {
                        addDishForm
                    } else {
                        hireChefForm
                    }
                }
            }
            .navigationTitle(mode == .addDish ? "Add New Dish" : "Hire a Chef")
            .toolbar { toolbarContent }
            .sheet(item: Binding(get: {
                recipeResult.map { RecipeSheetData(title: $0.title, ingredients: $0.ingredients, steps: $0.steps) }
            }, set: { _ in
                recipeResult = nil
            })) { sheet in
                RecipeSheetView(data: sheet) {
                    Task {
                        try? await APIService.shared.saveRecipe(title: sheet.title, description: nil, ingredients: sheet.ingredients, steps: sheet.steps)
                        recipeResult = nil
                        dismissSheet()
                    }
                }
            }
        }
    }
}

#Preview {
    AddDishView(dish: .constant(MockData.dishes[0])) { }.environmentObject(SessionViewModel())
}

// MARK: - Recipe sheet
private struct RecipeSheetData: Identifiable {
    let id = UUID()
    let title: String
    let ingredients: [String]
    let steps: [String]
}

private struct RecipeSheetView: View {
    let data: RecipeSheetData
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Ingredients") {
                    ForEach(data.ingredients, id: \.self) { Text($0) }
                }
                Section("Steps") {
                    ForEach(Array(data.steps.enumerated()), id: \.offset) { i, s in
                        HStack(alignment: .top) {
                            Text("\(i+1).").bold()
                            Text(s)
                        }
                    }
                }
            }
            .navigationTitle(data.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save to Profile") { onSave() }
                }
            }
        }
    }
}

// MARK: - Subviews & helpers
extension AddDishView {
    @ViewBuilder
    var addDishForm: some View {
        Section("Basics") {
            TextField("Dish name", text: $dish.title)
            TextField("Description", text: $dish.description, axis: .vertical)
                .lineLimit(3...6)
            TextField("Cuisine", text: $dish.cuisine)
        }

        Section("Photo") {
            Button(photoPicked ? "Photo Selected" : "Upload Photo") {
                // Placeholder for image picker integration for dish photo
                photoPicked.toggle()
            }
            .tint(.brandGreen)
        }

        Section("Price or Barter") {
            Toggle("Cook for share (barter)", isOn: $dish.barter)
            if !dish.barter {
                TextField("Price (e.g. 9.99)", text: $priceText)
                    .keyboardType(.decimalPad)
                    .onChange(of: priceText) { _, v in
                        dish.price = Double(v.filter { "0123456789.".contains($0) })
                    }
            } else {
                Text("No payment, help cook and share").foregroundStyle(.secondary)
            }
        }

        Section("Ingredients") {
            ForEach(Array(dish.ingredients.enumerated()), id: \.offset) { i, ing in
                TextField("Ingredient", text: Binding(
                    get: { ing },
                    set: { dish.ingredients[i] = $0 }
                ))
            }
            Button("Add ingredient") { dish.ingredients.append("") }
                .tint(.brandGreen)
        }

        Section("Dietary") {
            ForEach(dietaryOptions, id: \.self) { opt in
                Toggle(opt, isOn: Binding(
                    get: { dish.dietary.contains(opt) },
                    set: { newVal in
                        if newVal { dish.dietary.append(opt) } else { dish.dietary.removeAll { $0 == opt } }
                    }
                ))
            }
        }

        Section("AI Tag Suggestions") {
            TagChipsView(tags: dish.tags)
            HStack {
                TextField("Add tag", text: $tagText)
                Button("Add") {
                    let t = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    dish.tags.append(t)
                    tagText = ""
                }
                .tint(.brandGreen)
            }
            HStack {
                Button {
                    Task { await suggestTagsFromAI() }
                } label: {
                    if isTagLoading { ProgressView() } else { Label("Suggest Tags", systemImage: "sparkles") }
                }
                .buttonStyle(.borderedProminent)
                .tint(.brandGreen)
                Text("Tags are suggested by AI (editable)").font(.footnote).foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    @ViewBuilder
    var hireChefForm: some View {
        Section("Request") {
            TextField("What should the chef cook? (e.g. Thai curry, pasta)", text: $requestTitle, axis: .vertical)
                .lineLimit(2...4)
            VStack(alignment: .leading, spacing: 8) {
                TagChipsView(tags: hireTags)
                HStack {
                    TextField("Add tag (e.g. spicy, vegan)", text: $hireTagText)
                    Button("Add") {
                        let t = hireTagText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !t.isEmpty else { return }
                        hireTags.append(t)
                        hireTagText = ""
                    }
                    .tint(.brandGreen)
                }
            }
        }

        Section("Your Pantry") {
            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 6, matching: .images) {
                Label(pantryImages.isEmpty ? "Upload pantry photos" : "Add more photos", systemImage: "photo.on.rectangle.angled")
            }
            .tint(.brandGreen)
            .onChange(of: selectedPhotos) { _, items in
                Task {
                    pantryImages.removeAll()
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                            pantryImages.append(img)
                        }
                    }
                }
            }

            if !pantryImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(pantryImages.enumerated()), id: \.offset) { _, uiImg in
                            Image(uiImage: uiImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }

            VStack(alignment: .leading) {
                ForEach(Array(pantryItems.enumerated()), id: \.offset) { i, item in
                    TextField("Ingredient", text: Binding(
                        get: { item },
                        set: { pantryItems[i] = $0 }
                    ))
                }
                HStack {
                    TextField("Add ingredient (e.g. chicken, tomatoes)", text: $pantryNewItem)
                    Button("Add") {
                        let t = pantryNewItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !t.isEmpty else { return }
                        pantryItems.append(t)
                        pantryNewItem = ""
                    }
                    .tint(.brandGreen)
                }
            }
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if mode == .addDish {
                Button("Save") { onSave() }
                    .disabled(dish.title.isEmpty || dish.description.isEmpty)
            } else {
                Button("Request") {
                    Task { await submitHireChef() }
                }
            }
        }
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismissSheet() }
        }
    }

    private func dismissSheet() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.keyWindow?.rootViewController?.dismiss(animated: true)
        }
    }

    private struct HireChefRequest: Encodable {
        let title: String
        let tags: [String]
        let pantry: [String]
        let imagesBase64: [String]
    }

    private func submitHireChef() async {
        isRecipeLoading = true
        // Convert images to base64 strings
        let base64s: [String] = pantryImages.compactMap { ui in ui.jpegData(compressionQuality: 0.6)?.base64EncodedString() }
        do {
            let recipe = try await APIService.shared.aiPantryRecipe(imagesBase64: base64s, pantry: pantryItems)
            self.recipeResult = (title: recipe.title, ingredients: recipe.ingredients, steps: recipe.steps)
        } catch {
            self.recipeResult = (title: "AI Recipe", ingredients: pantryItems, steps: ["Unable to generate detailed steps right now."])
        }
        isRecipeLoading = false
    }

    private func suggestTagsFromAI() async {
        isTagLoading = true
        let source = [dish.title, dish.description, dish.cuisine, dish.ingredients.joined(separator: ", ")]
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n")
        do {
            let tags = try await APIService.shared.aiSuggestTags(text: source, max: 8)
            var merged = Set(dish.tags.map { $0.lowercased() })
            for t in tags { merged.insert(t.lowercased()) }
            dish.tags = Array(merged).sorted()
        } catch { /* ignore */ }
        isTagLoading = false
    }
}
