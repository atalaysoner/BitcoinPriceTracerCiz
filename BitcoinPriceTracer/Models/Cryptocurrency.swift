import Foundation

struct Cryptocurrency: Identifiable, Hashable {
    let id: String
    let symbol: String
    let name: String
    
    static let availableCryptos = [
        Cryptocurrency(id: "BTCUSDT", symbol: "BTC", name: "Bitcoin"),
        Cryptocurrency(id: "ETHUSDT", symbol: "ETH", name: "Ethereum"),
        Cryptocurrency(id: "BNBUSDT", symbol: "BNB", name: "Binance Coin"),
        Cryptocurrency(id: "ADAUSDT", symbol: "ADA", name: "Cardano"),
        Cryptocurrency(id: "DOGEUSDT", symbol: "DOGE", name: "Dogecoin"),
        Cryptocurrency(id: "XRPUSDT", symbol: "XRP", name: "Ripple"),
        Cryptocurrency(id: "DOTUSDT", symbol: "DOT", name: "Polkadot"),
        Cryptocurrency(id: "SOLUSDT", symbol: "SOL", name: "Solana")
    ]
} 