//
//  MessageProtocol.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

protocol MessageProtocol: Codable, Hashable, Equatable {
	var id: String { get }
	var content: MessageContent { get }
	var sender: User { get }
	var date: Date {get }
	var isRead: Bool { get }
	var status: MessageStatus { get }
	var replyTo: (any MessageProtocol)? { get }
}

enum MessageContent: Codable, Hashable {
	case text(String)
	case docs([String])
	
	var dbValues: [String: AnyHashable] {
		switch self {
		case .text(let string):
			return [
				"content": string,
				"type": "TEXT"
			]
		case .docs(let docs):
			return [
				"content": docs,
				"type": "DOCS"
			]
		}
	}
}

enum MessageStatus: Codable, Equatable, Hashable {
	case sending
	case sent
	case failed
}

struct Message: MessageProtocol {
	var id: String
	var content: MessageContent
	var sender: User
	var date: Date
	var isRead: Bool
	var status: MessageStatus
	var replyTo: (any MessageProtocol)?
	
	init(
		id: String,
		content: MessageContent,
		sender: User,
		date: Date,
		isRead: Bool,
		status: MessageStatus,
		replyTo: (any MessageProtocol)? = nil
	) {
		self.id = id
		self.content = content
		self.sender = sender
		self.date = date
		self.isRead = isRead
		self.replyTo = replyTo
		self.status = status
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.content = try container.decode(MessageContent.self, forKey: .content)
		self.sender = try container.decode(User.self, forKey: .sender)
		self.date = try container.decode(Date.self, forKey: .date)
		self.isRead = try container.decode(Bool.self, forKey: .isRead)
		// Will always be sent as the server already has access to it
		self.status = .sent
		// TODO: Implement as an enhancement
		self.replyTo = nil
	}
	
	private enum CodingKeys: String, CodingKey {
		case id, content, sender, date, isRead
	}
	
	func encode(to encoder: any Encoder) throws {
		// Implement when needed
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	static func == (lhs: Message, rhs: Message) -> Bool {
		lhs.id == rhs.id
	}
	
	// For database storage
	var dbValues: [String: AnyHashable] {[
		"id": id,
		"content": content.dbValues,
		"sender": sender.dbValues,
		"date": date.iSOTimestamp,
		"is_read": isRead,
		"reply_to": replyTo?.id
	]}
}

// MARK: - Mocks
extension Message {
	static let mocks = [
		Message(
			id: UUID().uuidString,
			content: .text("Hello"),
			sender: User(id: "ninos", name: "Nicolas", avator: nil),
			date: Date().removing(minutes: 20),
			isRead: true,
			status: .sent
		),
		Message(
			id: UUID().uuidString,
			content: .text("Hello"),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().removing(minutes: 19),
			isRead: true,
			status: .sent
		),
		Message(
			id: UUID().uuidString,
			content: .text("Hi"),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().removing(minutes: 18),
			isRead: true,
			status: .sent
		),
		Message(
			id: UUID().uuidString,
			content: .text("Are you fine?"),
			sender: User(id: "ninos", name: "Nicolas", avator: nil),
			date: Date().removing(minutes: 16),
			isRead: true,
			status: .sent
		),
		Message(
			id: UUID().uuidString,
			content: .text("Yes and I'm coding"),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().removing(minutes: 14),
			isRead: true,
			status: .sent
		),
		Message(
			id: UUID().uuidString,
			content: .text("Proof"),
			sender: User(id: "ninos", name: "Nicolas", avator: nil),
			date: Date().removing(minutes: 10),
			isRead: true,
			status: .sent
		),
		Message(
			id: UUID().uuidString,
			content: .docs([""]),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().removing(minutes: 3),
			isRead: true,
			status: .sent
		)
	]
}
