public class StorageUser {

	private static let kId = "id"
	private static let kName = "name"
	private static let kChoices = "choices"

	public let id: Int
	public let name: String
	public private(set) var choices: [StorageUserChoice]

	public var dictionary: [String : Any] {
		let choiceDictionaries = self.choices.map { $0.dictionary }
		let dict: [String : Any] = [
			StorageUser.kId : self.id,
			StorageUser.kName : self.name,
			StorageUser.kChoices : choiceDictionaries
		]

		return dict
	}

	public required init(id: Int, name: String?, choices: [StorageUserChoice] = []) {
		self.id = id
		self.name = name ?? "Unknown"
		self.choices = choices
	}

	public convenience init(dictionary: [String : Any]) {
		let id = dictionary[StorageUser.kId] as? Int ?? -1
		let name = dictionary[StorageUser.kName] as? String
		let choiceDictionaries: [[String : Any]] = dictionary[StorageUser.kChoices] as? [[String : Any]] ?? []
		let choices = choiceDictionaries.map { StorageUserChoice(dictionary: $0) }

		self.init(id: id, name: name, choices: choices)
	}

	public func addChoice(for messageId: Int, caption: String?, order: Int) {
		var newChoices = self.choices.filter { $0.messageId != messageId }
		let choice = StorageUserChoice(messageId: messageId, caption: caption, order: order)
		newChoices.append(choice)
		self.choices = newChoices
	}

	public func haveChoice(for messageId: Int, with order: Int) -> Bool {
		if let choice = self.choice(for: messageId) {
			return choice.order == order
		}

		return false
	}

	public func haveChoice(for messageId: Int) -> Bool {
		let choice = self.choice(for: messageId)
		return choice != nil
	}

	public func choice(for messageId: Int) -> StorageUserChoice? {
		let choice = self.choices.first(where: { choice -> Bool in
			choice.messageId == messageId
		})

		return choice
	}

}

public class StorageUserChoice {

	private static let kMessageId = "messageId"
	private static let kCaption = "caption"
	private static let kOrder = "order"

	public let messageId: Int
	public let caption: String
	public let order: Int

	public var dictionary: [String : Any] {
		let dict: [String : Any] = [
			StorageUserChoice.kMessageId : self.messageId,
			StorageUserChoice.kCaption : self.caption,
			StorageUserChoice.kOrder : self.order
		]

		return dict
	}

	public required init(messageId: Int, caption: String?, order: Int) {
		self.messageId = messageId
		self.caption = caption ?? "Unknown choice"
		self.order = order
	}

	public convenience init(dictionary: [String : Any]) {
		let messageId = dictionary[StorageUserChoice.kMessageId] as? Int ?? -1
		let caption = dictionary[StorageUserChoice.kCaption] as? String
		let orderId = dictionary[StorageUserChoice.kOrder] as? Int ?? -1

		self.init(messageId: messageId, caption: caption, order: orderId)
	}

}
