import Foundation
import TelegramBot
import SwiftyJSON

internal class PostStorage {

	private static let kPostReplyItemsKey = "postReplyItems"
	private static let kStorageMessagesKey = "storageMessages"
	private static let kStorageUsersKey = "storageUsers"

	private var postReplyItems: [String : Any]

	private var storageMessages: [StorageMessage]
	private var storageUsers: [StorageUser]

	init() {
		self.postReplyItems = UserDefaults.standard.dictionary(forKey: PostStorage.kPostReplyItemsKey) ?? [:]

		let messageDisctionaries: [[String : Any]] = UserDefaults.standard.array(forKey: PostStorage.kStorageMessagesKey)
			as? [[String : Any]]  ?? []
		self.storageMessages = messageDisctionaries.map { StorageMessage(dictionary: $0) }

		let userDisctionaries: [[String : Any]] = UserDefaults.standard.array(forKey: PostStorage.kStorageUsersKey)
			as? [[String : Any]]  ?? []
		self.storageUsers = userDisctionaries.map { StorageUser(dictionary: $0) }
	}

	internal func add(replyMarkup: InlineKeyboardMarkup, buttons: [String], for message: Message) {
		let messageId = String(message.message_id)
		let dict = replyMarkup.json.dictionaryObject ?? [:]
		self.postReplyItems.updateValue(dict, forKey: messageId)

		let storageMessage = StorageMessage(id: message.message_id, text: message.text, buttons: buttons)
		self.storageMessages.append(storageMessage)
	}

	internal func register(user: User, for messageId: Int, order: Int) {
		let user = self.existingUser(for: user)
		user.addChoice(for: messageId, caption: nil, order: order)
	}

	private func existingUser(for user: User) -> StorageUser {
		if let existingUser = self.storageUsers.first(where: { existing -> Bool in return existing.id == Int(user.id) }) {
			return existingUser
		}

		let newUser = StorageUser(id: Int(user.id), name: user.username)
		self.storageUsers.append(newUser)
		return newUser
	}

	private func existingMessage(for messageId: Int) -> StorageMessage? {
		let existingMessage = self.storageMessages.first(where: { existing -> Bool in return existing.id == messageId })
		return existingMessage
	}

	internal func voices(for messageId: Int) -> Int {
		let voices: Int = self.storageUsers.reduce(0) { (result, user) -> Int in
			let delta = user.haveChoice(for: messageId) ? 1 : 0
			return result + delta
		}

		return voices
	}

	internal func allResults() -> String {
		let allResults = self.storageMessages.reduce("") { return $0 + self.results(for: $1.id) + "\n" }
		return allResults
	}

	internal func results(for messageId: Int) -> String {
		guard let storedMessage = self.existingMessage(for: messageId) else { return "Нет результатов 😔" }

		let votedUsers = self.storageUsers.filter { $0.haveChoice(for: messageId) }
		var text = storedMessage.caption + "\n"

		for (order, button) in storedMessage.buttons.enumerated() {
			let voteCount = votedUsers.reduce(0, { (result, user) -> Int in
				let delta = user.haveChoice(for: messageId, with: order) ? 1 : 0
				return result + delta
			})

			let voteCaption = "\(order + 1). \(button) : *\(voteCount)*\n"
			text = text + voteCaption
		}

		return text
	}

	internal func replyMarkup(for messageId: Int) -> InlineKeyboardMarkup? {
		guard let markupKeyboardDict = self.postReplyItems[String(messageId)] as? [String : Any] else { return nil }
		let json = JSON(markupKeyboardDict)
		let markup = InlineKeyboardMarkup(json: json)
		return markup
	}

	internal func synchronize() {
		UserDefaults.standard.setValue(self.postReplyItems, forKey: PostStorage.kPostReplyItemsKey)

		let userDictionaries = self.storageUsers.map { $0.dictionary }
		UserDefaults.standard.setValue(userDictionaries, forKey: PostStorage.kStorageUsersKey)

		let messageDictionaries = self.storageMessages.map { $0.dictionary }
		UserDefaults.standard.setValue(messageDictionaries, forKey: PostStorage.kStorageMessagesKey)

		UserDefaults.standard.synchronize()
	}

	internal func dropAllItems() {
		self.postReplyItems = [:]
		UserDefaults.standard.setValue([:], forKey: PostStorage.kPostReplyItemsKey)

		self.storageUsers = []
		UserDefaults.standard.setValue([:], forKey: PostStorage.kStorageUsersKey)

		self.storageMessages = []
		UserDefaults.standard.setValue([:], forKey: PostStorage.kStorageMessagesKey)
	}

}
