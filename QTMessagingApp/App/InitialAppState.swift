//
//  InitialAppState.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 25/09/2026.
//

import SwiftUI

@MainActor
@Observable
class InitialAppState {
	var appLoadingState: AppLoadingState = .loading
	var userInfo: User?
	
	init() {
		// Current user data from Userdefaults values
		let userName: String? = LocalProperties(.userName).wrappedValue
		let userId: String? = LocalProperties(.userId).wrappedValue
		if let userId, UUID(uuidString: userId) != nil, let userName {
			self.userInfo = User(id: userId, name: userName, avator: nil)
		}
		appLoadingState = .loaded
	}
	
	func updateUserInfo(with user: User) {
		// Update local userdefault values
		LocalProperties<String?>(.userId).wrappedValue = user.id
		LocalProperties<String?>(.userName).wrappedValue = user.name
		self.userInfo = user
	}
	
	enum AppLoadingState: Equatable {
		case loading
		case loaded
	}
}
