import Vapor
import TelegramVaporBot



// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let TGBOT: TGBotConnection = .init()
//    Обратить внимание на эту строку - в пустых скобках должен быть токен бота, выданный в BotFather
    let tgApi: String = ""
    /// set level of debug if you needed
//    ниже создаётся экземляр самого бота и держится подключение бота (setConnection) по long plling. Веб хуки в данном проекте не реализованы, но вообще либа их поддерживает
    TGBot.log.logLevel = app.logger.logLevel
    let bot: TGBot = .init(app: app, botId: tgApi)
    await TGBOT.setConnection(try await TGLongPollingConnection(bot: bot))
    await DefaultBotHandlers.addHandlers(app: app, connection: TGBOT.connection)
    try await TGBOT.connection.start()
//    строки ниже конфигурируют хост и порт. На Google Compute Engine может не запуститься с портом 80, в настройках VM нужно разрешить доступ по http для этого
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 80
    // register routes
    try routes(app)
}
