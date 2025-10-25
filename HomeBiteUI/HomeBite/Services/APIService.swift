import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case server(Int, String)
    case decoding(Error)
    case encoding
    case unauthorized
    case network(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .server(let code, let msg): return "Server error (\(code)): \(msg)"
        case .decoding: return "Failed to decode response"
        case .encoding: return "Failed to encode request"
        case .unauthorized: return "Unauthorized"
        case .network(let err): return err.localizedDescription
        case .unknown: return "Unknown error"
        }
    }
}

struct APIConfig {
    static var shared = APIConfig()
    // iOS Simulator can hit localhost of the Mac
    var baseURL: URL = URL(string: "http://localhost:8000/api")!
}

final class APIService {
    static let shared = APIService()
    private init() {}

    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let jsonEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "hb_access_token") }
        set { UserDefaults.standard.setValue(newValue, forKey: "hb_access_token") }
    }

    // MARK: - DTOs
    struct TokenOut: Codable { let access_token: String; let token_type: String; let user: APIUser }
    struct APIUser: Codable { let id: UUID; let full_name: String?; let email: String; let role: String; let avatar_url: String?; let campus_id: UUID? }

    struct APIDish: Codable {
        let id: UUID
        let cook_id: UUID
        let title: String
        let description: String?
        let price: Double
        let currency: String
        let available: Bool
        let available_qty: Int?
        let prep_time_minutes: Int?
        let pickup_location: String?
        let campus_id: UUID?
        let images: [String]
        let tags: [String]
    }

    struct APIOrderItemIn: Codable { let dish_id: UUID; let quantity: Int; let special_instructions: String? }
    struct APIOrderItemOut: Codable { let id: UUID; let dish_id: UUID?; let quantity: Int; let unit_price: Double; let total_price: Double; let special_instructions: String? }
    struct APIOrder: Codable { let id: UUID; let buyer_id: UUID; let cook_id: UUID?; let status: String; let total: Double; let currency: String; let scheduled_pickup: String?; let pickup_notes: String?; let pickup_location: String?; let items: [APIOrderItemOut] }

    // MARK: - Core request
    private func request<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil, authorized: Bool = false) async throws -> T {
        guard let url = URL(string: path, relativeTo: APIConfig.shared.baseURL) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do { req.httpBody = try jsonEncoder.encode(AnyEncodable(body)) } catch { throw APIError.encoding }
        }
        if authorized {
            guard let token = accessToken else { throw APIError.unauthorized }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }
            if http.statusCode == 401 { throw APIError.unauthorized }
            if !(200...299).contains(http.statusCode) {
                let msg = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
                throw APIError.server(http.statusCode, msg)
            }
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            if let apiErr = error as? APIError { throw apiErr }
            return try { throw APIError.network(error) }()
        }
    }

    private struct AnyEncodable: Encodable {
        private let enc: (Encoder) throws -> Void
        init(_ encodable: Encodable) { self.enc = encodable.encode }
        func encode(to encoder: Encoder) throws { try enc(encoder) }
    }

    // MARK: - Auth
    struct SignupIn: Codable { let full_name: String?; let email: String; let password: String; let role: String; let campus_id: UUID? }
    struct LoginIn: Codable { let email: String; let password: String }

    @discardableResult
    func signup(fullName: String?, email: String, password: String, role: String, campusId: UUID?) async throws -> APIUser {
        let payload = SignupIn(full_name: fullName, email: email, password: password, role: role, campus_id: campusId)
        let tokenOut: TokenOut = try await request("/auth/signup", method: "POST", body: payload)
        self.accessToken = tokenOut.access_token
        return tokenOut.user
    }

    @discardableResult
    func login(email: String, password: String) async throws -> APIUser {
        let tokenOut: TokenOut = try await request("/auth/login", method: "POST", body: LoginIn(email: email, password: password))
        self.accessToken = tokenOut.access_token
        return tokenOut.user
    }

    // MARK: - Dishes
    func fetchDishes(campusId: UUID? = nil, query: String? = nil, tags: [String] = []) async throws -> [APIDish] {
        var comps = URLComponents(url: APIConfig.shared.baseURL.appendingPathComponent("/dishes"), resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = []
        if let campusId { items.append(URLQueryItem(name: "campus_id", value: campusId.uuidString)) }
        if let query, !query.isEmpty { items.append(URLQueryItem(name: "q", value: query)) }
        if !tags.isEmpty { items.append(URLQueryItem(name: "tags", value: tags.joined(separator: ","))) }
        comps.queryItems = items
        let path = comps.url!.path + (comps.percentEncodedQuery.map { "?\($0)" } ?? "")
        return try await request(path)
    }

    func createDish(title: String, description: String?, price: Double, availableQty: Int?, prepTimeMinutes: Int?, pickupLocation: String?, campusId: UUID?, imageURLs: [String], tags: [String]) async throws -> APIDish {
        struct APIDishImage: Codable { let url: String; let sort_order: Int? }
        struct DishCreateIn: Codable {
            let title: String; let description: String?; let price: Double; let currency: String; let available: Bool; let available_qty: Int?; let prep_time_minutes: Int?; let pickup_location: String?; let campus_id: UUID?; let images: [APIDishImage]; let tags: [String]
        }
        let images = imageURLs.enumerated().map { APIDishImage(url: $0.element, sort_order: $0.offset) }
        let payload = DishCreateIn(title: title, description: description, price: price, currency: "USD", available: true, available_qty: availableQty, prep_time_minutes: prepTimeMinutes, pickup_location: pickupLocation, campus_id: campusId, images: images, tags: tags)
        return try await request("/dishes", method: "POST", body: payload, authorized: true)
    }

    // MARK: - Orders
    func createOrder(items: [APIOrderItemIn], scheduledISO8601: String?, pickupNotes: String?, pickupLocation: String?) async throws -> APIOrder {
        struct OrderCreateIn: Codable { let items: [APIOrderItemIn]; let scheduled_pickup: String?; let pickup_notes: String?; let pickup_location: String?; let currency: String }
        let payload = OrderCreateIn(items: items, scheduled_pickup: scheduledISO8601, pickup_notes: pickupNotes, pickup_location: pickupLocation, currency: "USD")
        return try await request("/orders", method: "POST", body: payload, authorized: true)
    }

    func fetchOrders(as role: String = "buyer") async throws -> [APIOrder] {
        var comps = URLComponents(url: APIConfig.shared.baseURL.appendingPathComponent("/orders"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "as", value: role)]
        let path = comps.url!.path + "?\(comps.percentEncodedQuery!)"
        return try await request(path, authorized: true)
    }

    // MARK: - Ratings
    func addRating(dishId: UUID, score: Int, comment: String?) async throws {
        struct RatingIn: Codable { let dish_id: UUID; let score: Int; let comment: String? }
        let _: Empty = try await request("/ratings", method: "POST", body: RatingIn(dish_id: dishId, score: score, comment: comment), authorized: true)
    }

    private struct Empty: Codable {}
}
