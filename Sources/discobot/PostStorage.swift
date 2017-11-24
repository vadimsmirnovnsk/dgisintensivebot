import Foundation
import TelegramBot
import SwiftyJSON

internal class PostStorage {

	private static let postReplyItemsKey = "postReplyItems"

	private var postReplyItems: [String : Any] = UserDefaults.standard.dictionary(forKey: PostStorage.postReplyItemsKey) ?? [:]
	private var users: [String : [String : Any]] = [:]

	init() { }

	internal func add(replyMarkup: InlineKeyboardMarkup, for messageId: Int) {
		let dict = replyMarkup.json.dictionaryObject ?? [:]
		self.postReplyItems.updateValue(dict, forKey: String(messageId))
	}

	internal func register(user: User, for messageId: Int, choice: String) {
		let userId = String(user.id)

		var userDict = self.users[userId] ?? [:]
		userDict.updateValue(choice, forKey: String(messageId))
		self.users.updateValue(userDict, forKey: userId)
	}

	internal func voices(for messageId: Int) -> Int {
		var voices = 0
		for user in users {
			if user.value[String(messageId)] != nil {
				voices = voices + 1
			}
		}

		return voices
	}

	internal func replyMarkup(for messageId: Int) -> InlineKeyboardMarkup? {
		guard let markupKeyboardDict = self.postReplyItems[String(messageId)] as? [String : Any] else { return nil }
		let json = JSON(markupKeyboardDict)
		let markup = InlineKeyboardMarkup(json: json)
		return markup
	}

	internal func synchronize() {
		UserDefaults.standard.setValue(self.postReplyItems, forKey: PostStorage.postReplyItemsKey)
		UserDefaults.standard.synchronize()
	}

	internal func dropAllItems() {
		self.postReplyItems = [:]
		UserDefaults.standard.setValue([:], forKey: PostStorage.postReplyItemsKey)
	}

}
