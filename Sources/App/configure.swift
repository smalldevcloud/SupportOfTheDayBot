import Vapor
import TelegramVaporBot



// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let TGBOT: TGBotConnection = .init()
    let tgApi: String = ""
    /// set level of debug if you needed
    TGBot.log.logLevel = app.logger.logLevel
    let bot: TGBot = .init(app: app, botId: tgApi)
    await TGBOT.setConnection(try await TGLongPollingConnection(bot: bot))
    await DefaultBotHandlers.addHandlers(app: app, connection: TGBOT.connection)
    try await TGBOT.connection.start()
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 80
    // register routes
    try routes(app)
}
