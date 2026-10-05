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
}
