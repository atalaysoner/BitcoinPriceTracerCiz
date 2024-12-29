//
//  ContentView.swift
//  BitcoinPriceTracer
//
//  Created by Soner Atalay on 29.12.2024.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var refreshInterval: Double = 60
    @State private var currentPrice: String = "0.00"
    @State private var previousPrice: String = "0.00"
    @State private var isTracking: Bool = false
    @State private var timer: Timer?
    @State private var trackingMode: TrackingMode = .timed
    @State private var selectedCrypto: Cryptocurrency = Cryptocurrency.availableCryptos[0]
    @State private var showCryptoPicker = false
    @State private var priceChangeThreshold: Double = 1.0 // Varsayılan %1
    @State private var selectedLanguage: Language = .turkish
    
    private let cryptoService = CryptoPriceService()
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // Binance teması renkleri
    private let binanceYellow = Color(hex: "FCD535")
    private let binanceDark = Color(hex: "1E2026")
    private let binanceGray = Color(hex: "474D57")
    
    enum TrackingMode {
        case timed
        case instant
    }
    
    var body: some View {
        ZStack {
            binanceDark.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Dil seçici
                HStack {
                    Spacer()
                    Menu {
                        ForEach(Language.allCases) { language in
                            Button(action: {
                                selectedLanguage = language
                            }) {
                                HStack {
                                    Text(language.displayName)
                                    if selectedLanguage == language {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "globe")
                            .foregroundColor(binanceYellow)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                // Kripto seçici butonu
                Button(action: { showCryptoPicker = true }) {
                    HStack {
                        Text(selectedCrypto.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .foregroundColor(binanceYellow)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(binanceGray.opacity(0.3))
                    .cornerRadius(16)
                }
                
                // Fiyat gösterimi
                VStack {
                    Text("\(selectedCrypto.symbol)/USDT")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("$\(currentPrice)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(binanceYellow)
                    
                    if let currentDouble = Double(currentPrice),
                       let previousDouble = Double(previousPrice),
                       previousDouble != 0 {
                        let change = ((currentDouble - previousDouble) / previousDouble) * 100
                        Text(String(format: "%.2f%%", change))
                            .font(.subheadline)
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                }
                .padding()
                .background(binanceGray.opacity(0.3))
                .cornerRadius(16)
                
                // Takip modu seçici
                VStack(alignment: .leading, spacing: 12) {
                    Text(Localizable.text(for: .trackingMode, language: selectedLanguage))
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    Picker("Takip Modu", selection: $trackingMode) {
                        Text(Localizable.text(for: .timedMode, language: selectedLanguage))
                            .tag(TrackingMode.timed)
                        Text(Localizable.text(for: .priceChangeMode, language: selectedLanguage))
                            .tag(TrackingMode.instant)
                    }
                    .pickerStyle(.segmented)
                    .tint(binanceYellow)
                }
                .padding()
                .background(binanceGray.opacity(0.3))
                .cornerRadius(16)
                
                if trackingMode == .timed {
                    // Zaman aralığı seçici (mevcut hali)
                    TimeIntervalPicker(refreshInterval: $refreshInterval, selectedLanguage: $selectedLanguage, binanceYellow: binanceYellow, binanceGray: binanceGray)
                } else {
                    // Fiyat değişimi yüzdesi seçici
                    VStack(alignment: .leading) {
                        Text(Localizable.text(for: .priceChangePercentage, language: selectedLanguage))
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        HStack {
                            Slider(value: $priceChangeThreshold, in: 0.1...10.0, step: 0.1)
                                .tint(binanceYellow)
                            
                            Text("%\(String(format: "%.1f", priceChangeThreshold))")
                                .foregroundColor(.white)
                                .frame(width: 60)
                        }
                        
                        Text(Localizable.text(for: .notifyWhenPriceChanges, language: selectedLanguage))
                            .foregroundColor(binanceGray)
                            .font(.caption)
                    }
                    .padding()
                    .background(binanceGray.opacity(0.3))
                    .cornerRadius(16)
                }
                
                // Başlat/Durdur butonu
                Button(action: {
                    isTracking.toggle()
                    if isTracking {
                        startTracking()
                    } else {
                        stopTracking()
                    }
                }) {
                    HStack {
                        Image(systemName: isTracking ? "pause.circle.fill" : "play.circle.fill")
                        Text(isTracking ? Localizable.text(for: .stop, language: selectedLanguage) : Localizable.text(for: .start, language: selectedLanguage))
                    }
                    .font(.headline)
                    .foregroundColor(binanceDark)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(binanceYellow)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showCryptoPicker) {
            CryptoPickerView(selectedCrypto: $selectedCrypto, selectedLanguage: $selectedLanguage)
                .presentationDetents([.medium])
        }
        .onChange(of: selectedCrypto) { _ in
            if isTracking {
                stopTracking()
                startTracking()
            } else {
                Task {
                    await updatePrice()
                }
            }
        }
        .onDisappear {
            stopTracking()
        }
    }
    
    private func startTracking() {
        Task {
            await updatePrice()
        }
        
        switch trackingMode {
        case .timed:
            startTimedTracking()
        case .instant:
            startInstantTracking()
        }
    }
    
    private func startTimedTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task {
                await updatePrice()
            }
        }
    }
    
    private func startInstantTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task {
                await checkPriceChange()
            }
        }
    }
    
    private func checkPriceChange() async {
        do {
            let newPrice = try await cryptoService.fetchPrice(for: selectedCrypto.id)
            await MainActor.run {
                if let current = Double(newPrice), let previous = Double(currentPrice) {
                    let changePercent = abs(((current - previous) / previous) * 100)
                    
                    if changePercent >= priceChangeThreshold {
                        previousPrice = currentPrice
                        currentPrice = newPrice
                        speakPrice(newPrice, isChange: true, changePercent: changePercent)
                    }
                }
            }
        } catch {
            print("Fiyat kontrolü sırasında hata: \(error.localizedDescription)")
        }
    }
    
    private func updatePrice() async {
        do {
            let newPrice = try await cryptoService.fetchPrice(for: selectedCrypto.id)
            await MainActor.run {
                previousPrice = currentPrice
                currentPrice = newPrice
                speakPrice(newPrice, isChange: false)
            }
        } catch {
            print("Fiyat güncellenirken hata: \(error.localizedDescription)")
        }
    }
    
    private func stopTracking() {
        timer?.invalidate()
        timer = nil
        isTracking = false
    }
    
    private func speakPrice(_ price: String, isChange: Bool, changePercent: Double? = nil) {
        var message = ""
        
        if isChange {
            if let current = Double(price), let previous = Double(previousPrice) {
                let direction = current > previous ? 
                    Localizable.text(for: .priceIncreased, language: selectedLanguage) :
                    Localizable.text(for: .priceDecreased, language: selectedLanguage)
                
                if let percent = changePercent {
                    if selectedLanguage == .turkish {
                        message = "\(selectedCrypto.name) fiyatı yüzde \(String(format: "%.1f", percent)) \(direction). Yeni fiyat \(price) Amerikan Doları"
                    } else {
                        message = "The price of \(selectedCrypto.name) has \(direction) by \(String(format: "%.1f", percent))%. New price is \(price) US Dollars"
                    }
                }
            }
        } else {
            if selectedLanguage == .turkish {
                message = "\(selectedCrypto.name)'in güncel fiyatı \(price) Amerikan Doları"
            } else {
                message = "The current price of \(selectedCrypto.name) is \(price) US Dollars"
            }
        }
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage.locale)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
}

// Kripto seçim görünümü
struct CryptoPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCrypto: Cryptocurrency
    @Binding var selectedLanguage: Language
    
    var body: some View {
        NavigationView {
            List(Cryptocurrency.availableCryptos, id: \.id) { crypto in
                Button(action: {
                    selectedCrypto = crypto
                    dismiss()
                }) {
                    HStack {
                        Text(crypto.name)
                        Spacer()
                        Text(crypto.symbol)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(Localizable.text(for: .selectCrypto, language: selectedLanguage))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Hex renk kodu için extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Zaman aralığı seçici için yeni view
struct TimeIntervalPicker: View {
    @Binding var refreshInterval: Double
    @Binding var selectedLanguage: Language
    let binanceYellow: Color
    let binanceGray: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(Localizable.text(for: .notificationInterval, language: selectedLanguage))
                .foregroundColor(.white)
                .font(.subheadline)
            
            Slider(value: $refreshInterval, in: 10...300, step: 10)
                .tint(binanceYellow)
            
            Text("\(Int(refreshInterval)) \(Localizable.text(for: .seconds, language: selectedLanguage))")
                .foregroundColor(binanceGray)
                .font(.caption)
        }
        .padding()
        .background(binanceGray.opacity(0.3))
        .cornerRadius(16)
    }
}

#Preview {
    ContentView()
}
