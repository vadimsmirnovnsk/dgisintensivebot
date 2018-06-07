import Foundation

public class StorageMessage {

	private static let kId = "id"
	private static let kText = "text"
	private static let kButtons = "buttons"

	public let id: Int
	public let text: String
	public let buttons: [String]

	public var dictionary: [String : Any] {
		let dict: [String : Any] = [
			StorageMessage.kId : self.id,
			StorageMessage.kText : self.text,
			StorageMessage.kButtons : self.buttons
		]

		return dict
	}

	public var caption: String {
		let captionArray = self.text.split(separator: "\n")
		let rawCaption = captionArray.first ?? ""
		let caption = "*\(rawCaption)*"
		return caption
	}

	public required init(id: Int, text: String?, buttons: [String]?) {
		self.id = id
		self.text = text ?? ""
		self.buttons = buttons ?? []
	}

	public convenience init(dictionary: [String : Any]) {
		let id = dictionary[StorageMessage.kId] as? Int ?? -1
		let text = dictionary[StorageMessage.kText] as? String
		let buttons = dictionary[StorageMessage.kButtons] as? [String] ?? []

		self.init(id: id, text: text, buttons: buttons)
	}

}
