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
    var body: some View {
		NavigationStack {
			if let userId, let userName {
				ChatListView(currentUser: User(id: userId, name: userName, avator: nil))
			} else {
				UserNameView {
					// Using this completion to observe the content change in setting the user name
				}
			}
		}
    }
}

#Preview {
    ContentView()
}
