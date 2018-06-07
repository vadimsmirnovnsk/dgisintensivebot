import Foundation

public extension String {

	private static let voiceString = "\n🤔 Проголосовало: "

	public func textByAdd(voices: Int) -> String {
		var text = self

		if let range = self.range(of: String.voiceString) {
			text = self.substring(to: range.lowerBound)
		}

		text = text + String.voiceString
		text = text + String(voices)

		return text
	}

	private func haveVoices() -> Bool {
		let haveVoiceString = self.contains(String.voiceString)
		return haveVoiceString
	}

}
