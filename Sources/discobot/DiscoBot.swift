import Foundation
import TelegramBot

public class DiscoBot {

	public static let replyButtonData = "replyButtonData"
	private static let replyMarkup = "reply_markup"

	private let discoStorage = PostStorage()

	public func postForm(chatId: ChatId, title: String, description: String, buttons: [String], test: Bool) {
		let markdownedTitle = "*" + title + "*\n"
		let text = markdownedTitle + description
		let replyMarkupKeyboard = DiscoBot.inlineKeyboard(with: buttons)
		let replyMarkup = DiscoBot.replyMarkup(with: replyMarkupKeyboard)

		let prodChatId = test ? chatId : Config.channelPrivateId
		bot.sendMessageAsync(chat_id: prodChatId,
							 text: text,
							 parse_mode: "markdown",
							 replyMarkup) { [weak self] message, error in
			if let message = message {
				DispatchQueue.main.async {
					self?.discoStorage.add(replyMarkup: replyMarkupKeyboard, buttons: buttons, for: message)
					self?.discoStorage.synchronize()
				}

				if (!test) {
					let userName = message.from?.username ?? "Unknown"
					let postedText = "*\(userName) запостил опрос:*\n" +
						"Title: \(title)\n" +
						"id: \(message.message_id)"

					bot.sendMessageAsync(chat_id: Config.vados,
										 text: postedText,
										 parse_mode: "markdown")
					if chatId.json.intValue != Config.vados {
						bot.sendMessageAsync(chat_id: chatId,
											 text: postedText,
											 parse_mode: "markdown")
					}
				}
			}
		}
	}

	public func postResult(message: Message, query: Int) {
		let text = self.discoStorage.results(for: query)

		let chatId = Config.approvedUserIds.contains(message.chat.id)
			? message.chat.id
			: Config.vados
		bot.sendMessageAsync(chat_id: chatId,
							 text: text,
							 parse_mode: "markdown")
	}

	public func postResults(message: Message) {
		let text = self.discoStorage.allResults()

		let chatId = Config.approvedUserIds.contains(message.chat.id)
			? message.chat.id
			: Config.vados
		bot.sendMessageAsync(chat_id: chatId,
							 text: text,
							 parse_mode: "markdown")
	}

	public func processChoice(for query: CallbackQuery) {
		guard let message = query.message else { return }
		DispatchQueue.main.async {
			if let markupKeyboard = self.discoStorage.replyMarkup(for: message.message_id) {

				let user = query.from
				let markup = DiscoBot.replyMarkup(with: markupKeyboard)
				let choiceString = query.data ?? "-1"
				let choice = Int(choiceString) ?? -1

				self.discoStorage.register(user: user, for: message.message_id, order: choice)
				self.discoStorage.synchronize()

				var text = message.text ?? ""
				let voices = self.discoStorage.voices(for: message.message_id)
				text = text.textByAdd(voices: voices)

				bot.editMessageTextAsync(chat_id: message.chat.id,
										 message_id: message.message_id,
										 text: text, markup)
			}
		}
	}

	public func dropDatabase() {
		self.discoStorage.dropAllItems()
	}

	// Echo fallback
	public func processFallback(message: Message, errorDescription: String? = nil) {
		if let from = message.from, let text = message.text {
			var messageText = "Hi \(from.first_name)! You said: \(text).\nBut I know only command: /post\n"
			if let errorDescription = errorDescription {
				messageText = messageText + errorDescription + "\n"
			}

			bot.sendMessageAsync(chat_id: from.id,
			                     text: messageText,
			                     parse_mode: "markdown")
		}
	}

	public func printInfo(chatId: ChatId, info: String) {
		bot.sendMessageAsync(chat_id: chatId,
							 text: info,
							 parse_mode: "markdown")
	}

	private class func inlineKeyboard(with buttons: [String]) -> InlineKeyboardMarkup {
		var counter = 0
		let inlineButtons: [[InlineKeyboardButton]] = buttons.map {
			var inlineButton = InlineKeyboardButton()
			inlineButton.text = $0
			inlineButton.callback_data = String(counter)
			counter = counter + 1

			return [inlineButton]
		}

		var keyboardMarkup = InlineKeyboardMarkup()
		keyboardMarkup.inline_keyboard = inlineButtons

		return keyboardMarkup
	}

	internal class func replyMarkup(with keyboard: InlineKeyboardMarkup) -> [String : Any] {
		return ["reply_markup": keyboard]
	}

	public func isApprovedForChat(userId: Int64) -> Bool {
		guard Config.approvedUserIds.contains(userId) else {
			let info = "Вы не можете управлять ботом, сорян."
			bot.sendMessageAsync(chat_id: userId,
			                     text: info,
			                     parse_mode: "markdown")

			return false
		}

		return true
	}
}
