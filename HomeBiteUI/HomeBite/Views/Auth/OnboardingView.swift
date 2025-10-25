import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var isLoading = false
    @State private var isLogin = false
    @FocusState private var focused: Bool
    
    private let dietaryOptions = ["Vegetarian","Vegan","Gluten-Free","Halal","Kosher"]
    private let cuisineOptions = ["Italian","Thai","Indian","Mexican","Chinese","American"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("CampusBites")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.brandGreen)
                        .padding(.top, 24)
                    Text("Share, buy, or sell home-cooked meals on campus.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Name", text: $session.name)
                                .textContentType(.name)
                                .submitLabel(.next)
                                .focused($focused)
                                .bordered()
                            TextField("University", text: $session.university)
                                .textContentType(.organizationName)
                                .submitLabel(.next)
                                .focused($focused)
                                .bordered()
                            TextField("Email", text: $session.email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .submitLabel(.next)
                                .focused($focused)
                                .bordered()
                            SecureField("Password", text: $session.password)
                                .textContentType(.password)
                                .submitLabel(.done)
                                .bordered()
                        }
                    } label: { Label(isLogin ? "Login" : "Create Account", systemImage: "person.crop.circle.fill") }
                    .glassBackgroundEffect()

                    // Preferences
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dietary restrictions").font(.headline)
                        FlowLayout(dietaryOptions, id: \.self) { option in
                            SelectChip(text: option, isSelected: session.dietary.contains(option)) {
                                if let idx = session.dietary.firstIndex(of: option) { session.dietary.remove(at: idx) }
                                else { session.dietary.append(option) }
                            }
                        }
                        .padding(.vertical, 6)
                        
                        Text("Cuisine preferences").font(.headline)
                        FlowLayout(cuisineOptions, id: \.self) { option in
                            SelectChip(text: option, isSelected: session.cuisines.contains(option)) {
                                if let idx = session.cuisines.firstIndex(of: option) { session.cuisines.remove(at: idx) }
                                else { session.cuisines.append(option) }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .padding()
                    .glassContainer(cornerRadius: 16)
                    
                    Button(action: submit) {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Text(isLogin ? "Login" : "Continue")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.brandGreen))
                        .foregroundStyle(.white)
                    }
                    .disabled(isLoading || session.email.isEmpty || session.password.isEmpty)
                    
                    Button(isLogin ? "Need an account? Sign up" : "Already have an account? Log in") {
                        isLogin.toggle()
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func submit() {
        Task {
            isLoading = true
            await session.loginOrSignup()
            isLoading = false
        }
    }
}

// MARK: - Supporting small components
struct SelectChip: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? Color.brandGreen.opacity(0.2) : Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.brandGreen : .clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct FlowLayout<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    var data: Data
    var id: KeyPath<Data.Element, ID>
    @ViewBuilder var content: (Data.Element) -> Content
    
    init(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.content = content
    }
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(Array(data), id: id) { item in
                    content(item)
                        .padding(4)
                        .alignmentGuide(.leading) { d in
                            if (abs(width - d.width) > geometry.size.width) {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if item as AnyObject === data.last as AnyObject {
                                width = 0
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { d in
                            let result = height
                            if item as AnyObject === data.last as AnyObject {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
        .frame(height: intrinsicHeight)
    }
    
    private var intrinsicHeight: CGFloat { 120 }
}
