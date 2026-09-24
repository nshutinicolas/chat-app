//
//  ContentView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct ContentView: View {
	@LocalProperties(.userId) var userId: String?
	@LocalProperties(.userName) var userName: String?
	@State private var userInfo: User?
	
	init() { }
	
    var body: some View {
		NavigationStack {
			if let userInfo {
				ChatListView(currentUser: userInfo)
			} else {
				UserNameView()
			}
		}
		.onAppear {
			guard let userId, let userName else { return }
			userInfo = User(id: userId, name: userName, avator: nil)
		}
    }
}

#Preview {
    ContentView()
}

@Observable
class UserLocalInfo {
	var userId: String
	var userName: String
	
	init(userId: String, userName: String) {
		self.userId = userId
		self.userName = userName
	}
	
}
