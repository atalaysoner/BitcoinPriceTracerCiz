import Foundation

enum Language: String, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
    
    var locale: String {
        switch self {
        case .turkish: return "tr-TR"
        case .english: return "en-US"
        }
    }
}

struct Localizable {
    static func text(for key: LocalizableKey, language: Language) -> String {
        switch language {
        case .turkish:
            return key.turkish
        case .english:
            return key.english
        }
    }
}

enum LocalizableKey {
    case trackingMode
    case timedMode
    case priceChangeMode
    case notificationInterval
    case priceChangePercentage
    case notifyWhenPriceChanges
    case start
    case stop
    case selectCrypto
    case seconds
    case currentPrice
    case priceIncreased
    case priceDecreased
    
    var turkish: String {
        switch self {
        case .trackingMode: return "Takip Modu"
        case .timedMode: return "Zamanlı"
        case .priceChangeMode: return "Fiyat Değişimi"
        case .notificationInterval: return "Bildirim Aralığı"
        case .priceChangePercentage: return "Fiyat Değişim Yüzdesi"
        case .notifyWhenPriceChanges: return "Fiyat %%.1f değiştiğinde bildirim al"
        case .start: return "Başlat"
        case .stop: return "Durdur"
        case .selectCrypto: return "Kripto Seç"
        case .seconds: return "saniye"
        case .currentPrice: return "'in güncel fiyatı"
        case .priceIncreased: return "yükseldi"
        case .priceDecreased: return "düştü"
        }
    }
    
    var english: String {
        switch self {
        case .trackingMode: return "Tracking Mode"
        case .timedMode: return "Timed"
        case .priceChangeMode: return "Price Change"
        case .notificationInterval: return "Notification Interval"
        case .priceChangePercentage: return "Price Change Percentage"
        case .notifyWhenPriceChanges: return "Notify when price changes by %.1f%%"
        case .start: return "Start"
        case .stop: return "Stop"
        case .selectCrypto: return "Select Crypto"
        case .seconds: return "seconds"
        case .currentPrice: return "current price is"
        case .priceIncreased: return "increased"
        case .priceDecreased: return "decreased"
        }
    }
} 