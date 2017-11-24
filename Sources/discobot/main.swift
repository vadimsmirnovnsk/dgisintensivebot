import Foundation
import TelegramBot
import CoreData

let bot = TelegramBot(token: Config.botToken)
let router = Router(bot: bot)
let discoBot = DiscoBot()

router["post2", .slashRequired] = { context in
	if let message = context.message {
		let p = context.args.scanWords()
		print("Will process: \(p)")

		guard let user = message.from, discoBot.isApprovedForChat(userId: user.id) else { return true }

		if let messageText = message.text {
			let textLines = messageText.components(separatedBy: "\n")
			guard textLines.count > 3 else { return true }
			let title = textLines[1]
			let description = textLines[2]

			let buttons = Array<String>(textLines[3..<textLines.count])
			print("Title: " + title)
			print("Description: " + description)
			print("Buttons: \(buttons)")

			discoBot.postForm(chatId: message.chat.id, title: title, description: description, buttons: buttons)
		}
	}

	return true
}

router[["help", "start"], .slashRequired] = { context in
	if let message = context.message {
		guard let user = message.from, discoBot.isApprovedForChat(userId: user.id) else { return true }

		let firstName = message.from?.first_name ?? "Неизвестный"
		let info = "Привет, " + firstName + "\n Используй команды:\n" +
		"*/clear* — чтобы дропнуть все записи из кеша\n" +
		"*/post* — отправить текст с кнопками в канальчик\n" +
		"*/results* — посмотреть результаты"
		bot.sendMessageAsync(chat_id: message.chat.id,
		                     text: info,
		                     parse_mode: "markdown")
	}

	return true
}

router["results", .slashRequired] = { context in
	if let message = context.message {
		guard let user = message.from, discoBot.isApprovedForChat(userId: user.id) else { return true }
		print("See results")
	}

	return true
}

router.add(.callback_query(data: nil)) { context -> Bool in
	if let query = context.update.callback_query {
		discoBot.processChoice(for: query)
	}

	return true
}

while true {
	while let update = bot.nextUpdateSync() {
		try router.process(update: update)
	}

	print("Server stopped due to error: \(String(describing: bot.lastError))")
	sleep(5)
}

fatalError("Server stopped due to error: \(String(describing: bot.lastError))")
