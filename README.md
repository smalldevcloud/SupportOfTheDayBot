# SupportOfTheDayBot

##### Пример телеграм-бота, написанного на swift. 
##### Что делает: по нажатию на кнопку в чате с ботом берёт случайную картинку с http.cat и привязав к ней рандомную подпись из массива подписей, заданного в проекте, отсылает в переписку сообщение, давая узнать какой ты сегодня специалист техподдержки.
![alt text](https://github.com/smalldevcloud/SupportOfTheDayBot/blob/main/Public/screenshot.jpg?raw=true)
##### Что использует: 
 [Vapor](https://vapor.codes/) - веб-фреймворк на Swift
 [Telegram Vapor Bot](https://github.com/nerzh/telegram-vapor-bot) - обёртка для облегчения работы с апи телеграма - https://github.com/nerzh/telegram-vapor-bot 
 [http.cat](https://http.cat/) - сайт, возвращаю смешные картинки с котиками для каждого из http-статусов
 [Google Compute Engine](cloud.google.com) - хостинг, на котором можно захостить своего бота для его непрерывной работы 
##### Что ещё:
#####  Всё уже было подробно описано вот в [этой статье](https://biser.medium.com/how-to-create-a-telegram-bot-with-swift-using-vapor-d302d27b4844), за что большое спасибо [dimabiserov](https://github.com/dimabiserov)
#####  Я лишь чуть актуализировал (кое-что изменилось с 2021 года) 
 

Для того, чтобы сгенерировать проект на Vapor нужно сначала этот Vapor установить.
1.	Открыть терминал в нужной папке и если Vapor ещё не установлен выполнить комманды:
```
brew install vapor
```
```
vapor new newtgbot
```
    *newtgbot - это название, которое получит проект
2.	Vapor сгенерит проект, в нём открыть файл Package.swift
3.	В configure.swift добавить:
```swift
app.http.server.configuration.hostname = "0.0.0.0"
app.http.server.configuration.port = 80
```
4.	В Package.swift добавить в dependencies:
```swift
.package(url: "https://github.com/nerzh/telegram-vapor-bot", .upToNextMajor(from: "2.1.0")),
```
5.	В Package.swift добавить targets/dependencies:
```swift
.product(name: "TelegramVaporBot", package: "telegram-vapor-bot"),
```

В итоге у меня вышел такой Package (тесты я удалил потому что не использовал, их можно оставить)
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SupportOfTheDayBot",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
        .package(url: "https://github.com/nerzh/telegram-vapor-bot", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "TelegramVaporBot", package: "telegram-vapor-bot"),
            ]
        )
    ]
)
```
6.	Создать файл DefaultBotHandlers.swift:
```swift
import Vapor
import TelegramVaporBot
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class DefaultBotHandlers {
    private static let startCommand = "/start"
    private static let supCommand = "Какой я сегодня саппорт?"
    private static var sups = [
        "Загадочный саппорт",
        "Разъярённый саппорт",
        "Сонный саппорт",
        "Гениальный саппорт",
        "Весёлый саппорт",
        "Опасный саппорт",
        "Игривый саппорт",
        "Задумчивый саппорт",
        "Романтичный саппорт",
        "Грустный саппорт",
        "Преисполнившийся саппорт",
        "Уставший саппорт",
        "Больше не саппорт",
        "Заряженный саппорт",
        "Пьяный саппорт",
        "Обматерённый саппорт",
        "Саппорт ставший чековым принтером",
        "Саппорт синтегрированный с кассой",
        "Саппорт забывший где взять данные для привязки ",
        "Саппорт хлебнувший тестов акций",
        "Расплавленный саппорт",
        "Саппорт съевший клиента",
        "Саппорт Шрёдингера"
    ]
    private static var codes = [
        "100",
        "101",
        "102",
        "103",
        "200",
        "201",
        "202",
        "203",
        "204",
        "205",
        "206",
        "207",
        "300",
        "301",
        "302",
        "303",
        "304",
        "305",
        "306",
        "307",
        "400",
        "401",
        "402",
        "403",
        "404",
        "405",
        "406",
        "407",
        "408",
        "409",
        "410",
        "411",
        "412",
        "413",
        "414",
        "415",
        "416",
        "417",
        "418",
        "422",
        "423",
        "424",
        "425",
        "426",
        "449",
        "450",
        "500",
        "501",
        "502",
        "503",
        "504",
        "505",
        "506",
        "507",
        "509",
        "510"
    ]

    static func addHandlers(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await defaultBaseHandler(app: app, connection: connection)
        await commandStartHandler(app: app, connection: connection)
        
    }

    private static func commandStartHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCommandHandler(commands: [startCommand]) { update, bot in

            let button: TGKeyboardButton = .init(text: "Какой я сегодня саппорт?")
            let rkm: TGReplyKeyboardMarkup = .init(keyboard: [[button]], resizeKeyboard: true)
            let reply: TGReplyMarkup = .replyKeyboardMarkup(rkm)

            try await update.message?.reply(text: "Тут ты можешь узнать, какой ты сегодня саппорт. Жми на кнопку", bot: bot, replyMarkup: reply)
        })
    }
    
    /// Handler for all updates
    private static func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGBaseHandler({ update, bot in
            guard let message = update.message else { return }
            
            if message.text == supCommand {
                guard let message = update.message else { return }
                var img = Data()
                if let url = URL(string: "https://http.cat/\(codes[Int.random(in: 0..<codes.count)])") {
                    img = try Data(contentsOf: url)
                }
                let photoTG = TGInputFile(filename: "file", data: img)
                var params: TGSendPhotoParams = .init(chatId: .chat(message.chat.id), photo: .file(photoTG))
                params.caption = sups[Int.random(in: 0..<sups.count)]
                try await connection.bot.sendPhoto(params: params)
            } else {
//                здесь можно добавить рекцию на любое другое сообщение
            }
        }))
    }
}
```
7.  Создать файл TGBotConnectionActor:
```swift
import Foundation
import TelegramVaporBot

actor TGBotConnection {
    private var _connection: TGConnectionPrtcl!

    var connection: TGConnectionPrtcl {
        self._connection
    }
    
    func setConnection(_ conn: TGConnectionPrtcl) {
        self._connection = conn
    }
}
```
8.  Снова в configure.swift добавить в функцию строки, где tgApi - токен бота:
```swift
let TGBOT: TGBotConnection = .init()
let tgApi: String = "YYYYYYYYYY:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
/// set level of debug if you needed
TGBot.log.logLevel = app.logger.logLevel
let bot: TGBot = .init(app: app, botId: tgApi)
await TGBOT.setConnection(try await TGLongPollingConnection(bot: bot))
await DefaultBotHandlers.addHandlers(app: app, connection: TGBOT.connection)
try await TGBOT.connection.start()
```
9. Запустить проект у себя. Уже на этом этапе бот будет работать, пока запущен проект.

Далее чуть-чуть расскажу как запустить его на виртуальной машине в Google Compute Engine, чтобы бот мог работать постоянно. 
Почему я выбрал его? Потому что он даёт какое-то время бесплатно поработать (2-3 месяца) прежде чем платить денюжку.

10. Пройти регистрацию в Google Compute Engine
11. Зайти в консоль управления console.cloud.google.com
12. В левой панели консоли выбрать пункт Compute Engine и в нём VM instances
13. В верхней панели кнопок нажать Create Instance
14. Тут нужно задать имя будущей виртуальной машины и её характеристики, для бота я выбрал самую дешёвую и самую хилую, с 1 ядром, т.к. логики у данного бота кот наплакал
15. На вкладке Firewall можно сразу поставить обе галочки Allow HTTP traffic и Allow HTTPs traffic (без этого будут проблемы с получением запросов от юзеров боту)
16. Создание может занять какое-то время, нужно подождать
17. Как только ВМ будет создана, она появиться в списке instances. Выделить её галочкой и запустить кнопкой START на панели вверху страницы
18. Теперь у этой ВМ в колонке Connect нажать на кнопку SSH, что позволит к ней подключиться
19. В открывшейся консоли нужно
```
sudo apt-get update
```
потом
```
sudo apt-get install clang libicu-dev libatomic1 build-essential pkg-config
```
потом
```
sudo apt-get install libssl-dev
```
20. Теперь необходимо установить сюда swift. Тк у меня вм создалась с debian на борту, использовать эту инструкцию (https://swift-arm.com/installSwift/)
```
curl -s https://packagecloud.io/install/repositories/swift-arm/release/script.deb.sh | sudo bash
```
затем 
```
sudo apt install swiftlang
```
21. Установить Vapor Toolbox (https://docs.vapor.codes/install/linux/)
```
git clone https://github.com/vapor/toolbox.git
```
```
cd toolbox
```
```
git checkout <desired version>
```
```
make install
```
22. Перейти в нужную дерикторию(а можно прямо и здесь) и клонировать проект с гитхаба (мой открытый, поэтому ничего попросит)
```
git clone https://github.com/smalldevcloud/SupportOfTheDayBot.git
```
23. Перейти в папку с проектом
```
cd SupportOfTheDayBot
```
24. Из папки с проектом сбилдить и запустить проект
```
vapor build
```
```
vapor run
```
---- Если начинает ругаться на какие-нибудь файлы вроде Package.resolved или с расширением .lock, то удалить их (добавить sudo, если access denied) и повторить запуск 
