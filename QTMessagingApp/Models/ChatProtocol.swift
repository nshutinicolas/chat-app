//
//  ChatProtocol.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

protocol ChatProtocol: Codable, Hashable {
	var id: String { get }
	// Making it optional for the initial message only
	var latestMessage: (any MessageProtocol)? { get }
	var participants: [User] {get }
}

extension ChatProtocol {
	func otherUser(not currentUser: User) -> User? {
		participants.first { $0.id != currentUser.id && $0.name != currentUser.name }
	}
}

struct Chat: ChatProtocol {
	var id: String
	var latestMessage: (any MessageProtocol)?
	var participants: [User]
	
	init(id: String, latestMessage: (any MessageProtocol)?, participants: [User]) {
		self.id = id
		self.latestMessage = latestMessage
		self.participants = participants
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		// When decoding for latest message, it should exist.
		self.latestMessage = try container.decode(Message.self, forKey: .latestMessage)
		self.participants = try container.decode([User].self, forKey: .participants)
	}
	
	func encode(to encoder: any Encoder) throws {
		// Implement when needed
	}
	
	enum CodingKeys: String, CodingKey {
		case id, latestMessage, participants
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	static func == (lhs: Chat, rhs: Chat) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: - Mocks

extension Chat {
	static let mocks = [
		Chat(
			id: UUID().uuidString,
			latestMessage: Message.mocks.first!,
			participants: [
				User(id: "ninos", name: "Nicolas", avator: nil),
				User(id: "siriro", name: "Siriro", avator: nil)
			]
		),
		Chat(
			id: UUID().uuidString,
			latestMessage: Message.mocks[1],
			participants: [
				User(id: "ninos", name: "Nicolas", avator: nil),
				User(id: "eriya", name: "Eriya M", avator: nil)
			]
		),
		Chat(
			id: UUID().uuidString,
			latestMessage: Message.mocks.last!,
			participants: [
				User(id: "ninos", name: "Nicolas", avator: nil),
				User(id: "kajuga", name: "Kajuga Protais", avator: nil)
			]
		)
	]
}

