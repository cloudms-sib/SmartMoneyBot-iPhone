import Foundation
import SwiftUI

@MainActor
final class BotStore: ObservableObject {
    @Published var mode: BotMode = .scanOnly
    @Published var settings = AppSettings()
    @Published var signals: [TradeSignal] = []
    @Published var isRunning = false
    @Published var brokerStatus = "Demo / Not connected"

    let symbols = ["EURUSD","GBPUSD","USDJPY","XAUUSD","US30","NAS100","SPX500","BTCUSD","PAIN400","PAIN500"]

    func scan() {
        signals = symbols.enumerated().map { i, symbol in
            StrategyEngine.analyze(symbol: symbol, candles: StrategyEngine.demoCandles(seed: i + 10))
        }
    }

    func toggleBot() {
        isRunning.toggle()
        if isRunning { scan() }
    }

    func connectBroker() async {
        switch await WeltradeAdapter().connect() {
        case .success(let message): brokerStatus = message
        case .unavailable(let message): brokerStatus = message
        }
    }
}
