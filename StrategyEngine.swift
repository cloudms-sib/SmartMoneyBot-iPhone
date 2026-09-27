import Foundation

struct StrategyEngine {
    static func ema(_ values: [Double], period: Int) -> Double? {
        guard !values.isEmpty else { return nil }
        let k = 2.0 / Double(period + 1)
        var result = values[0]
        for value in values.dropFirst() { result = value * k + result * (1 - k) }
        return result
    }

    static func analyze(symbol: String, candles: [Candle], sessionActive: Bool = true) -> TradeSignal {
        guard candles.count >= 10 else {
            return TradeSignal(symbol: symbol, direction: .wait, score: 0,
                structure: 0, liquidity: 0, zone: 0, orderBlock: 0, fvg: 0,
                ema: 0, session: 0, reason: "Not enough candle data")
        }

        let closes = candles.map(\.close)
        let fast = ema(closes, period: 12) ?? closes.last!
        let slow = ema(closes, period: 26) ?? closes.last!
        let previous = candles[candles.count - 6]
        let recent = Array(candles.suffix(5))
        let high = recent.map(\.high).max() ?? previous.high
        let low = recent.map(\.low).min() ?? previous.low
        let last = candles.last!
        let prior = candles[candles.count - 2]

        let bullStructure = last.close > previous.close
        let bearStructure = last.close < previous.close
        let sweptLow = last.low < low && last.close > low
        let sweptHigh = last.high > high && last.close < high
        let bullZone = last.close > last.open
        let bearZone = last.close < last.open
        let bullOB = prior.close < prior.open && bullStructure
        let bearOB = prior.close > prior.open && bearStructure
        let bullFVG = last.low > candles[candles.count - 3].high
        let bearFVG = last.high < candles[candles.count - 3].low

        var buy = 0, sell = 0
        if bullStructure { buy += 20 }; if bearStructure { sell += 20 }
        if sweptLow { buy += 20 }; if sweptHigh { sell += 20 }
        if bullZone { buy += 20 }; if bearZone { sell += 20 }
        if fast > slow { buy += 15 } else { sell += 15 }
        if sessionActive { buy += 10; sell += 10 }
        if bullOB { buy += 15 }; if bearOB { sell += 15 }
        if bullFVG { buy += 15 }; if bearFVG { sell += 15 }

        let score = max(buy, sell)
        let direction: SignalDirection = score >= 70 ? (buy >= sell ? .buy : .sell) : .wait
        let reason = direction == .buy ? "Bullish confluence detected" :
                     direction == .sell ? "Bearish confluence detected" : "No strong confluence"

        return TradeSignal(symbol: symbol, direction: direction, score: score,
            structure: max(bullStructure ? 20 : 0, bearStructure ? 20 : 0),
            liquidity: max(sweptLow ? 20 : 0, sweptHigh ? 20 : 0),
            zone: max(bullZone ? 20 : 0, bearZone ? 20 : 0),
            orderBlock: max(bullOB ? 15 : 0, bearOB ? 15 : 0),
            fvg: max(bullFVG ? 15 : 0, bearFVG ? 15 : 0),
            ema: 15, session: sessionActive ? 10 : 0, reason: reason)
    }

    static func demoCandles(seed: Int) -> [Candle] {
        var g = SeededGenerator(seed: UInt64(seed))
        var price = 100 + Double(seed % 20)
        return (0..<80).map { i in
            let move = Double.random(in: -1.2...1.2, using: &g)
            let open = price, close = price + move
            let high = max(open, close) + Double.random(in: 0...0.8, using: &g)
            let low = min(open, close) - Double.random(in: 0...0.8, using: &g)
            price = close
            return Candle(time: Date().addingTimeInterval(Double(i - 80) * 300),
                          open: open, high: high, low: low, close: close,
                          volume: Double.random(in: 100...1000, using: &g))
        }
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13; state ^= state >> 7; state ^= state << 17
        return state
    }
}
