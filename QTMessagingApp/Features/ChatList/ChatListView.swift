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
				// Create a shimmer view
				ProgressView("Loading chats...")
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
			case .error:
				VStack {
					Text("Failed to load messages")
						.foregroundStyle(.red)
					Button("Retry") { }
				}
			}
		}
		.sheet(isPresented: $showNewUserSelection) {
			VStack {
				Text("Start Chat with")
					.font(.title3.weight(.semibold))
					.padding()
				ScrollView {
					VStack {
						ForEach(User.mocks, id: \.id) { user in
							let newChat = Chat(id: UUID().uuidString, latestMessage: nil, participants: [currentUser, user])
							Button {
								showNewUserSelection = false
								coordinator.push(newChat)
							} label: {
								HStack {
									if let avator = currentUser.avator {
										AsyncImage(url: URL(string: avator)) { phase in
											if phase.error != nil {
												Circle()
													.fill(Color.gray)
													.frame(width: 40, height: 40)
											}
											if let image = phase.image {
												image.resizable()
													.scaledToFit()
													.frame(width: 40, height: 40)
											}
										}
									} else {
										Circle()
											.fill(Color.gray)
											.frame(width: 40, height: 40)
									}
									VStack(alignment: .leading) {
										Text(user.name)
											.fontWeight(.semibold)
										Text("@\(user.id)")
											.font(.caption)
											.foregroundStyle(.secondary)
									}
								}
								.frame(maxWidth: .infinity, alignment: .leading)
								.background()
							}
							.buttonStyle(.plain)
						}
					}
					.padding()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background()
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background()
		}
		.navigationTitle("Messages")
		.navigationDestination(for: Chat.self) { chat in
			ChatDetailsView(currentUser: currentUser, chat: chat)
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
