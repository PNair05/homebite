import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError(Int)
    case decodingFailed
    case encodingFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError(let code): return "Server error (\(code))"
        case .decodingFailed: return "Failed to decode response"
        case .encodingFailed: return "Failed to encode request"
        case .unknown: return "Unknown error"
        }
    }
}

final class APIService {
    static let shared = APIService()
    private init() {}
    
    // Replace with your FastAPI/NestJS base URL
    var baseURL = URL(string: "https://api.example.com")!
    
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
    
    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }
        guard (200..<300).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }
        do { return try jsonDecoder.decode(T.self, from: data) }
        catch { throw APIError.decodingFailed }
    }
    
    func post<T: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do { request.httpBody = try jsonEncoder.encode(body) } catch { throw APIError.encodingFailed }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }
        guard (200..<300).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }
        do { return try jsonDecoder.decode(T.self, from: data) }
        catch { throw APIError.decodingFailed }
    }
}
