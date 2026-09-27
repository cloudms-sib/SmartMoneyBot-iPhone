import SwiftUI

@main
struct SmartMoneyBotApp: App {
    @StateObject private var store = BotStore()
    var body: some Scene {
        WindowGroup { ContentView().environmentObject(store) }
    }
}
