//
//  ChatProtocol.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

protocol ChatProtocol: Codable {
	var id: String { get }
	var latestMessage: any MessageProtocol { get }
	var participants: [User] {get }
}

struct Chat: ChatProtocol {
	var id: String
	var latestMessage: any MessageProtocol
	var participants: [User]
	
	init(id: String, latestMessage: any MessageProtocol, participants: [User]) {
		self.id = id
		self.latestMessage = latestMessage
		self.participants = participants
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.latestMessage = try container.decode(Message.self, forKey: .latestMessage)
		self.participants = try container.decode([User].self, forKey: .participants)
	}
	
	func encode(to encoder: any Encoder) throws {
		// Implement when needed
	}
	
	enum CodingKeys: String, CodingKey {
		case id, latestMessage, participants
	}
}

// MARK: - Mocks

extension Chat {
	static let mocks = [
		Chat(
			id: UUID().uuidString,
			latestMessage: Message.mocks.first!,
			participants: [
				User(id: "me", name: "Nicolas", avator: nil),
				User(id: "other", name: "Nshuti", avator: nil)
			]
		),
		Chat(
			id: UUID().uuidString,
			latestMessage: Message.mocks[1],
			participants: [
				User(id: "me", name: "Nicolas", avator: nil),
				User(id: "other", name: "Nshuti", avator: nil)
			]
		),
		Chat(
			id: UUID().uuidString,
			latestMessage: Message.mocks.last!,
			participants: [
				User(id: "me", name: "Nicolas", avator: nil),
				User(id: "other", name: "Nshuti", avator: nil)
			]
		)
	]
}

