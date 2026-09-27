import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Dashboard", systemImage: "chart.xyaxis.line") }
            MarketsView().tabItem { Label("Markets", systemImage: "list.bullet.rectangle") }
            SignalsView().tabItem { Label("Signals", systemImage: "bolt.fill") }
            TradingView().tabItem { Label("Trading", systemImage: "arrow.left.arrow.right") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }.tint(.blue)
    }
}

struct DashboardView: View {
    @EnvironmentObject var store: BotStore
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GroupBox {
                        VStack(alignment: .leading) {
                            Text(store.isRunning ? "BOT RUNNING" : "BOT STOPPED").font(.headline)
                            Text(store.brokerStatus).foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        stat("Mode", store.mode.rawValue); stat("Timeframe", store.settings.timeframe)
                    }
                    HStack {
                        stat("Markets", "\(store.symbols.count)")
                        stat("Strong", "\(store.signals.filter { $0.score >= 70 }.count)")
                    }
                    Button(store.isRunning ? "STOP BOT" : "START SCANNER") { store.toggleBot() }
                        .buttonStyle(.borderedProminent).controlSize(.large)
                    Text("Prototype: local demo data only. Live execution is not connected.")
                        .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.padding()
            }.navigationTitle("Smart Money Bot")
        }
    }
    func stat(_ title: String, _ value: String) -> some View {
        VStack { Text(value).font(.headline); Text(title).font(.caption).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity).padding().background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct MarketsView: View {
    @EnvironmentObject var store: BotStore
    var body: some View {
        NavigationStack {
            List(store.signals) { s in
                HStack {
                    VStack(alignment: .leading) { Text(s.symbol).font(.headline); Text(s.reason).font(.caption).foregroundStyle(.secondary) }
                    Spacer()
                    VStack(alignment: .trailing) { Text(s.direction.rawValue).bold(); Text("\(s.score)/100").font(.caption) }
                }
            }.navigationTitle("Markets").toolbar { Button("Scan") { store.scan() } }
        }.onAppear { if store.signals.isEmpty { store.scan() } }
    }
}

struct SignalsView: View {
    @EnvironmentObject var store: BotStore
    var body: some View {
        NavigationStack {
            List(store.signals) { s in
                VStack(alignment: .leading, spacing: 8) {
                    HStack { Text(s.symbol).font(.headline); Spacer(); Text(s.direction.rawValue).bold() }
                    ProgressView(value: Double(s.score), total: 100)
                    Text("Score: \(s.score)/100").font(.caption).foregroundStyle(.secondary)
                    HStack { metric("Structure", s.structure); metric("Liquidity", s.liquidity); metric("Zone", s.zone) }
                    HStack { metric("OB", s.orderBlock); metric("FVG", s.fvg); metric("EMA", s.ema); metric("Session", s.session) }
                }.padding(.vertical, 6)
            }.navigationTitle("Signals")
        }.onAppear { if store.signals.isEmpty { store.scan() } }
    }
    func metric(_ n: String, _ v: Int) -> some View {
        VStack(alignment: .leading) { Text(n).font(.caption2).foregroundStyle(.secondary); Text("+\(v)").font(.caption).bold() }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TradingView: View {
    @EnvironmentObject var store: BotStore
    var body: some View {
        NavigationStack {
            Form {
                Section("Trading Mode") {
                    Picker("Mode", selection: $store.mode) {
                        ForEach(BotMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    if store.mode == .autoTrade {
                        Label("Auto Trade is locked until a supported broker API is connected.",
                              systemImage: "lock.fill").font(.footnote).foregroundStyle(.orange)
                    }
                }
                Section("Risk") {
                    HStack { Text("Risk"); Spacer(); Text("\(store.settings.riskPercent, specifier: "%.1f")%") }
                    Slider(value: $store.settings.riskPercent, in: 0.1...5, step: 0.1)
                    Stepper("Stop Loss: \(Int(store.settings.stopLossPips)) pips", value: $store.settings.stopLossPips, in: 5...200, step: 5)
                    Stepper("Take Profit: \(Int(store.settings.takeProfitPips)) pips", value: $store.settings.takeProfitPips, in: 5...500, step: 5)
                    Stepper("Max Trades: \(store.settings.maxTrades)", value: $store.settings.maxTrades, in: 1...10)
                }
                Section("Broker") {
                    Text(store.brokerStatus).font(.footnote)
                    Button("Test Broker Connection") { Task { await store.connectBroker() } }
                }
                Section { Button("Emergency Stop") { store.isRunning = false }.foregroundStyle(.red) }
            }.navigationTitle("Trading")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: BotStore
    var body: some View {
        NavigationStack {
            Form {
                Section("Strategy") {
                    LabeledContent("Timeframe", value: store.settings.timeframe)
                    LabeledContent("Minimum trade score", value: "70")
                    LabeledContent("EMA", value: "12 / 26")
                }
                Section("Markets") { ForEach(store.symbols, id: \.self) { Text($0) } }
                Section("Safety") {
                    Text("Live trading is disabled in this prototype.")
                    Text("Never put broker passwords or API secrets directly in source code.").foregroundStyle(.secondary)
                }
            }.navigationTitle("Settings")
        }
    }
}
