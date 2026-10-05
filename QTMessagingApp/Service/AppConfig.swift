//
//  AppConfig.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

enum AppConfig {
	static let serverURLKey = "serverURL"
	static let defaultServerURL = "http://localhost:8080"

	/// The Vapor server address. This is editable during sign-up so a physical
	/// device can connect to a server running on another machine on the LAN.
	static var baseURL: URL {
		let value = UserDefaults.standard.string(forKey: serverURLKey) ?? defaultServerURL
		return URL(string: value) ?? URL(string: defaultServerURL)!
	}

	static func socketURL(path: String, userID: UUID) -> URL? {
		guard var components = URLComponents(
			url: baseURL.appendingPathComponent(path),
			resolvingAgainstBaseURL: false
		) else { return nil }
		components.scheme = components.scheme == "https" ? "wss" : "ws"
		components.queryItems = [URLQueryItem(name: "user_id", value: userID.uuidString)]
		return components.url
	}
}
