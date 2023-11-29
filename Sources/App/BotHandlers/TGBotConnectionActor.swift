//
//  File.swift
//  
//
//  Created by 8 on 27.11.23.
//
import Vapor
import TelegramVaporBot
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class DefaultBotHandlers {
    private static let startCommand = "/start"
    private static let supCommand = "Какой я сегодня саппорт?"
    private static let addCommand = "/add"
    private static let supAddedStr = "Саппорт добавлен"
    
    private static var sups = [
        "Загадочный саппорт",
        "Разъярённый саппорт", 
        "Сонный саппорт",
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
        await commandSupHandler(app: app, connection: connection)
        await commandAddHandler(app: app, connection: connection)
        await commandImgHandler(app: app, connection: connection)
        
    }
    
    /// Handler for all updates
    private static func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGBaseHandler({ update, bot in
            guard let message = update.message else { return }
            
//            self.boops.append(message.text!)
            
            if message.text == supCommand {
                guard let message = update.message else { return }
                var img = Data()
                if let url = URL(string: "https://http.cat/\(codes[Int.random(in: 0..<codes.count)])") {
                    img = try Data(contentsOf: url)
                }
                let photoTG = TGInputFile(filename: "file", data: img)
                var params: TGSendPhotoParams = .init(chatId: .chat(message.chat.id), photo: .file(photoTG))
                params.caption = sups[Int.random(in: 0..<sups.count)]
    //            let txtParams: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: )
                try await connection.bot.sendPhoto(params: params)
    //            try await update.message?.photo(bot: bot, TGChatPhoto(from: <#T##Decoder#>))
            } else {
                
            }
//            let params: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: "///")
//            try await connection.bot.sendMessage(params: params)
        }))
    }

    /// Handler for Commands
    private static func commandStartHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCommandHandler(commands: [startCommand]) { update, bot in

            let button: TGKeyboardButton = .init(text: "Какой я сегодня саппорт?")
            let rkm: TGReplyKeyboardMarkup = .init(keyboard: [[button]], resizeKeyboard: true)

            let reply: TGReplyMarkup = .replyKeyboardMarkup(rkm)
            

            
            try await update.message?.reply(text: "Тут ты можешь узнать, какой ты сегодня саппорт. Жми на кнопку", bot: bot, replyMarkup: reply)
        })
    }

    private static func commandSupHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCommandHandler(commands: [supCommand]) { update, bot in
            guard let message = update.message else { return }
            var img = Data()
            if let url = URL(string: "https://caffesta.com/images/caffesta-logo.png") {
                img = try Data(contentsOf: url)
            }
            let photoTG = TGInputFile(filename: "file", data: img)
            var params: TGSendPhotoParams = .init(chatId: .chat(message.chat.id), photo: .file(photoTG))
            params.caption = sups[Int.random(in: 0..<sups.count)]
//            let txtParams: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: )
            try await connection.bot.sendPhoto(params: params)
        })
    }
    
    private static func commandAddHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCommandHandler(commands: [addCommand]) { update, bot in
            guard let message = update.message else { return }
            
            let text = message.text!
            let trimmedStr = text.replacingOccurrences(of: addCommand, with: "", options: NSString.CompareOptions.literal, range: nil)
            sups.append(trimmedStr)
            try await update.message?.reply(text: trimmedStr, bot: bot)
        })
    }
    
    private static func commandImgHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await connection.dispatcher.add(TGCommandHandler(commands: ["addImg"]) { update, bot in
            guard let message = update.message else { return }
            var img = Data()
            if let url = URL(string: "https://caffesta.com/images/caffesta-logo.png") {
                img = try Data(contentsOf: url)
            }
            let photoTG = TGInputFile(filename: "file", data: img)
            var params: TGSendPhotoParams = .init(chatId: .chat(message.chat.id), photo: .file(photoTG))
            params.caption = sups[Int.random(in: 0..<sups.count)]
//            let txtParams: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: )
            try await connection.bot.sendPhoto(params: params)
//            try await update.message?.photo(bot: bot, TGChatPhoto(from: <#T##Decoder#>))
        })
    }
}
