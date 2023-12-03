//
//  File.swift
//  
//
//  Created by 8 on 27.11.23.
//
import Vapor
import TelegramVaporBot
// такой импорт необходим для запуска на unix, иначе будет ругаться на Networking
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class DefaultBotHandlers {
//    строки, на котоые будут реагировать обработчики
    private static let startCommand = "/start"
    private static let supCommand = "Какой я сегодня саппорт?"
//    массив возможных саппортов
    private static var sups = [
        "Загадочный саппорт",
        "Разъярённый саппорт",
        "Сонный саппорт",
        "Геніяльны саппорт",
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
        "Личный саппорт райпо",
        "Обматерённый саппорт",
        "Саппорт ставший чековым принтером",
        "Саппорт синтегрированный с альфа-кассой",
        "Саппорт забывший где взять данные для привязки ",
        "Саппорт хлебнувший тестов акций",
        "Расплавленный саппорт",
        "Саппорт съевший клиента",
        "Саппорт Шрёдингера"
    ]
//    массив кодов http-запросов. Это необходимо для апи http.cat, которое вернёт картинку в ответ на такой код
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
//        функция добавляет перечисленные здесь обработчики. Если сделать обработчик, но не добавить его сюда - действовать он не будет!
        await defaultBaseHandler(app: app, connection: connection)
        await commandStartHandler(app: app, connection: connection)
        
    }

    private static func commandStartHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        чтобы запустить бота, юзер должен нажать кнопку START, она отправляет в чат комманду /start, на неё и среагирует этот обработчик. Он создаст для бота KeyboardButton (кнопку внизу, которая не скроллится и всегда прикреплена снизу), а так же отправляет небольшое объяснение пользователю, что делает данный бот.
        await connection.dispatcher.add(TGCommandHandler(commands: [startCommand]) { update, bot in

            let button: TGKeyboardButton = .init(text: "Какой я сегодня саппорт?")
            let rkm: TGReplyKeyboardMarkup = .init(keyboard: [[button]], resizeKeyboard: true)
            let reply: TGReplyMarkup = .replyKeyboardMarkup(rkm)

            try await update.message?.reply(text: "Тут ты можешь узнать, какой ты сегодня саппорт. Жми на кнопку", bot: bot, replyMarkup: reply)
        })
    }
    
    /// Handler for all updates
    private static func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        этот обработчик смотрит на все сообщения, приходящие в бот и в данном случае выполняет основную функцию, реагируя на текст единственной кнопки
        await connection.dispatcher.add(TGBaseHandler({ update, bot in
            guard let message = update.message else { return }
            
            if message.text == supCommand {
//                если текст сообщения совпадает с текстом кнопки - идеёт обращение к http.cat. Берётся рандомный элемент из массива http-кодов выше. В ответе приходит картинка, к которой так же рандомно подставляется саппорт из массива саппортов, который также объявлен выше.
                guard let message = update.message else { return }
                var img = Data()
                if let url = URL(string: "https://http.cat/\(codes[Int.random(in: 0..<codes.count)])") {
//                    получение картинки в виде Data
                    img = try Data(contentsOf: url)
                }
                let photoTG = TGInputFile(filename: "file", data: img)
                var params: TGSendPhotoParams = .init(chatId: .chat(message.chat.id), photo: .file(photoTG))
//                caption - подпись, которая будет под картинкой
                params.caption = sups[Int.random(in: 0..<sups.count)]
                app.logger.info("Запрос на саппорта дня")
                try await connection.bot.sendPhoto(params: params)
            } else {
//                здесь можно добавить рекцию на любое другое сообщение
                app.logger.info("\(message.text)")
            }
        }))
    }
}
