import Foundation
import Combine

class BitcoinPriceService: ObservableObject {
    private let binanceAPI = "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT"
    private var timer: Timer?
    
    func fetchPrice() async throws -> String {
        guard let url = URL(string: binanceAPI) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let bitcoinPrice = try JSONDecoder().decode(BitcoinPrice.self, from: data)
        
        // Fiyatı iki ondalık basamağa yuvarlama
        if let price = Double(bitcoinPrice.price) {
            return String(format: "%.2f", price)
        }
        
        return bitcoinPrice.price
    }
} 