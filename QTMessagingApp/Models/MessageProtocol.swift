//
//  MessageProtocol.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

protocol MessageProtocol: Codable {
	var id: String { get }
	var content: MessageContent { get }
	var sender: User { get }
	var date: Date {get }
	var isRead: Bool { get }
	var replyTo: (any MessageProtocol)? { get }
}

enum MessageContent: Codable {
	case text(String)
	case images([String])
	case files([String])
}

enum MessageStatus: Codable, Equatable {
	case sending
	case sent
	case failed
}

struct User: Codable {
	let id: String
	let name: String
	let avator: String?
}

struct Message: MessageProtocol {
	var id: String
	var content: MessageContent
	var sender: User
	var date: Date
	var isRead: Bool
	var replyTo: (any MessageProtocol)?
	
	init(
		id: String,
		content: MessageContent,
		sender: User,
		date: Date,
		isRead: Bool,
		replyTo: (any MessageProtocol)? = nil
	) {
		self.id = id
		self.content = content
		self.sender = sender
		self.date = date
		self.isRead = isRead
		self.replyTo = replyTo
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.content = try container.decode(MessageContent.self, forKey: .content)
		self.sender = try container.decode(User.self, forKey: .sender)
		self.date = try container.decode(Date.self, forKey: .date)
		self.isRead = try container.decode(Bool.self, forKey: .isRead)
		// TODO: Implement as an enhancement
		self.replyTo = nil
	}
	
	private enum CodingKeys: String, CodingKey {
		case id, content, sender, date, isRead
	}
	
	func encode(to encoder: any Encoder) throws {
		// Implement when needed
	}
}

// MARK: - Mocks
extension Message {
	static let mocks = [
		Message(
			id: UUID().uuidString,
			content: .text("Hello"),
			sender: User(id: "me", name: "Nicolas", avator: nil),
			date: Date().adding(minutes: 20),
			isRead: true
		),
		Message(
			id: UUID().uuidString,
			content: .text("Hello"),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().adding(minutes: 19),
			isRead: true
		),
		Message(
			id: UUID().uuidString,
			content: .text("Hi"),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().adding(minutes: 18),
			isRead: true
		),
		Message(
			id: UUID().uuidString,
			content: .text("Are you fine?"),
			sender: User(id: "me", name: "Nicolas", avator: nil),
			date: Date().adding(minutes: 16),
			isRead: true
		),
		Message(
			id: UUID().uuidString,
			content: .text("Yes and I'm coding"),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().adding(minutes: 14),
			isRead: true
		),
		Message(
			id: UUID().uuidString,
			content: .text("Proof"),
			sender: User(id: "me", name: "Nicolas", avator: nil),
			date: Date().adding(minutes: 10),
			isRead: true
		),
		Message(
			id: UUID().uuidString,
			content: .images([""]),
			sender: User(id: "other", name: "Nshuti", avator: nil),
			date: Date().adding(minutes: 3),
			isRead: true
		)
	]
}
