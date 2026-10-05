//
//  ChatListView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct ChatListView: View {
	@Environment(Coordinator.self) private var coordinator
	@State private var viewModel = ChatListViewModel()
	@State private var showNewUserSelection = false
	let currentUser: User
	
	init(currentUser: User) {
		self.currentUser = currentUser
	}
	
	var body: some View {
		VStack {
			switch viewModel.displayState {
			case .loading:
				ProgressView("Connecting to messages…")
			case .empty:
				ContentUnavailableView {
					Label("No messages yet", systemImage: "bubble.left.and.bubble.right")
				} description: {
					Text("Start a new conversation to see it here.")
				} actions: {
					Button("New message", systemImage: "square.and.pencil") {
						showNewUserSelection = true
					}
				}
			case .complete:
				ScrollView {
					LazyVStack {
						ForEach(viewModel.chats, id: \.id) { chat in
							if let user = chat.otherUser(not: currentUser) {
								Button {
									coordinator.push(chat)
								} label: {
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
										if let latestMessage = chat.latestMessage {
											Text(latestMessage.date.chatFormatted())
												.font(.caption)
										}
									}
									.frame(maxWidth: .infinity, alignment: .leading)
									.background()
								}
								.buttonStyle(.plain)
								Divider()
							}
						}
					}
					.padding()
				}
				.overlay(alignment: .bottomTrailing) {
					Button("", systemImage: "pencil") {
						showNewUserSelection = true
					}
					.font(.title3.weight(.semibold))
					.labelStyle(.iconOnly)
					.buttonStyle(.plain)
					.padding()
					.roundedBorder(for: .circle)
					.padding()
				}
			case .error(let message):
				VStack {
					Text(message)
						.foregroundStyle(.red)
					Text("Trying to reconnect…")
						.font(.footnote)
						.foregroundStyle(.secondary)
				}
			}
		}
		.sheet(isPresented: $showNewUserSelection) {
			NewMessageView(currentUser: currentUser) { chat in
				showNewUserSelection = false
				coordinator.push(chat)
			}
		}
		.navigationTitle("Messages")
		.navigationDestination(for: Chat.self) { chat in
			ChatDetailsView(currentUser: currentUser, chat: chat)
		}
		.task(id: currentUser.id) {
			await viewModel.run(for: currentUser.id)
		}
    }
	
	@ViewBuilder
	func chatRow(for chat: any ChatProtocol) -> some View {
		switch chat.latestMessage?.content {
		case .text(let text):
			Text(text)
		case .docs(let docs):
			Text("^[\(docs.count) document](inflect: true)")
		default:
			EmptyView()
		}
	}
}

#Preview {
	ChatListView(currentUser: User(id: "me", name: "Nicolas", avator: nil))
}
