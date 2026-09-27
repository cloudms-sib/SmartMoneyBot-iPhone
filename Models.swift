import Foundation

enum BotMode: String, CaseIterable, Identifiable {
    case scanOnly = "Scan Only"
    case askBeforeTrade = "Ask Before Trade"
    case autoTrade = "Auto Trade"
    var id: String { rawValue }
}

enum SignalDirection: String { case buy = "BUY", sell = "SELL", wait = "WAIT" }

struct Candle: Identifiable {
    let id = UUID()
    let time: Date
    let open, high, low, close, volume: Double
}

struct TradeSignal: Identifiable {
    let id = UUID()
    let symbol: String
    let direction: SignalDirection
    let score, structure, liquidity, zone, orderBlock, fvg, ema, session: Int
    let reason: String
}

struct AppSettings {
    var riskPercent = 1.0
    var stopLossPips = 25.0
    var takeProfitPips = 50.0
    var maxTrades = 2
    var timeframe = "M5"
}
