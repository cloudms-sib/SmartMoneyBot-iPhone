# Smart Money Bot — iPhone Prototype

This is the first standalone SwiftUI conversion of the uploaded trading robot.

Included:
- Dashboard
- Markets
- Signals
- Trading mode selector
- Risk, SL, TP and max-trade controls
- Emergency stop
- M5 strategy structure
- EMA 12/26
- Structure, liquidity, zone, order-block and FVG scoring
- 70-point signal threshold
- Demo candle data
- Broker adapter interface

The original Python robot directly uses the desktop MetaTrader 5 Python API. That desktop API cannot simply be used from an iPhone. This prototype therefore does not fake live Weltrade execution.

To run: on a Mac, create a new Xcode iOS App using SwiftUI, then add these Swift files. Target iOS 17+.

Next: connect a real market-data source, verify a supported broker execution API, then add secure Keychain credentials, order management and iOS background/notification handling. Test on demo before live trading.
