//
//  User.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 25/09/2026.
//

import Foundation

struct User: Codable, Hashable {
	let id: String
	let name: String
	let avator: String?
	
	var dbValues: [String: AnyHashable] {[
		"id": id,
		"name": name,
		"avator": avator
	].compactMapValues { $0 }}
}

// MARK: - Mocks
extension User {
	static var mocks: [User] = [
		User(id: "eric_1", name: "Eric Baller", avator: "https://xsgames.co/randomusers/assets/avatars/male/63.jpg"),
		User(id: "mandem", name: "Mazimpaka", avator: nil),
		User(id: "laptop", name: "Laptop Guy", avator: "https://xsgames.co/randomusers/assets/avatars/male/11.jpg"),
		User(id: "pneu", name: "Ma Tires", avator: nil)
	]
}
