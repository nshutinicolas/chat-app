//
//  ChatListView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct ChatListView: View {
	@State private var viewModel = ChatListViewModel()
	let currentUser: User
	
	init(currentUser: User) {
		self.currentUser = currentUser
	}
	
    var body: some View {
		VStack {
			switch viewModel.displayState {
			case .loading:
				// Create a shimmer view
				ProgressView("Loading chats...")
			case .complete:
				ScrollView {
					LazyVStack {
						ForEach(viewModel.chats, id: \.id) { chat in
							if let user = otherUser(for: chat) {
								HStack(alignment: .top) {
									Circle()
										.fill(Color.gray)
										.frame(width: 50, height: 50)
									VStack(alignment: .leading) {
										Text(user.name)
											.fontWeight(.semibold)
										chatRow(for: chat)
											.font(.caption)
									}
									.frame(maxWidth: .infinity, alignment: .leading)
									Text("12:00")
								}
								.frame(maxWidth: .infinity, alignment: .leading)
								Divider()
							}
						}
					}
					.padding()
				}
			case .error:
				VStack {
					Text("Failed to load messages")
						.foregroundStyle(.red)
					Button("Retry") { }
				}
			}
		}
		.onAppear {
			viewModel.fetchChats()
		}
    }
	
	func otherUser(for chat: any ChatProtocol) -> User? {
		chat.participants.first(where: { $0.id != currentUser.id })
	}
	
	@ViewBuilder
	func chatRow(for chat: any ChatProtocol) -> some View {
		switch chat.latestMessage.content {
		case .text(let text):
			Text(text)
		case .images(let images):
			Text("^[\(images.count) image](inflect: true)")
		case .files(let files):
			Text("^[\(files.count) file](inflect: true)")
		}
	}
}

#Preview {
	ChatListView(currentUser: User(id: "me", name: "Nicolas", avator: nil))
}
