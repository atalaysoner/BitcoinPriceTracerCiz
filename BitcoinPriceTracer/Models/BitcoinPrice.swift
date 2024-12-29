import Foundation

struct BitcoinPrice: Codable {
    let symbol: String
    let price: String
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case price = "price"
    }
} 