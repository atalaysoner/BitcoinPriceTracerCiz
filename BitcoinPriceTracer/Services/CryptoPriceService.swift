import Foundation
import Combine

class CryptoPriceService: ObservableObject {
    private let baseURL = "https://api.binance.com/api/v3/ticker/price"
    
    func fetchPrice(for symbol: String) async throws -> String {
        let urlString = "\(baseURL)?symbol=\(symbol)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let cryptoPrice = try JSONDecoder().decode(BitcoinPrice.self, from: data)
        
        if let price = Double(cryptoPrice.price) {
            return String(format: "%.2f", price)
        }
        
        return cryptoPrice.price
    }
} 