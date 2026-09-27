import Foundation

enum BrokerResult { case success(String), unavailable(String) }

protocol BrokerAdapter {
    var isConnected: Bool { get }
    func connect() async -> BrokerResult
    func placeOrder(symbol: String, direction: SignalDirection, volume: Double) async -> BrokerResult
}

struct WeltradeAdapter: BrokerAdapter {
    var isConnected: Bool { false }
    func connect() async -> BrokerResult {
        .unavailable("No supported custom-app execution API is connected.")
    }
    func placeOrder(symbol: String, direction: SignalDirection, volume: Double) async -> BrokerResult {
        .unavailable("Live Weltrade execution is not connected.")
    }
}
