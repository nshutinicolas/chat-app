//
//  ChatDetailsView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct ChatDetailsView: View {
	@State private var viewModel = ChatDetailsViewModel()
	let currentUser: User
	let chat: any ChatProtocol
	
	init(currentUser: User, chat: any ChatProtocol) {
		self.currentUser = currentUser
		self.chat = chat
	}
	
    var body: some View {
		VStack {
			switch viewModel.loadingState {
			case .loading:
				ProgressView("Loading messages")
			case .loaded:
				ChatMessagesView(currentUser: currentUser, messages: viewModel.messages)
			case .error:
				
			}
		}
		.safeAreaInset(edge: .bottom) {
			HStack {
				Button("", systemImage: "plus") {
					
				}
				.labelStyle(.iconOnly)
				.font(.title3.weight(.semibold))
				.padding(8)
				.clipShape(.circle)
				.overlay {
					Circle()
						.stroke(Color.gray, lineWidth: 1)
				}
				TextField("Enter a message", text: .constant(""))
					.font(.body)
					.lineLimit(1...6)
					.fixedSize(horizontal: false, vertical: true)
					.padding(.vertical, 12)
					.padding(.horizontal, 8)
					.overlay {
						RoundedRectangle(cornerRadius: 12)
							.stroke(Color.gray, lineWidth: 1)
					}
					.background()
					.clipShape(.rect(cornerRadius: 12))
			}
		}
		.padding()
    }
}

struct ChatMessagesView: View {
	let currentUser: User
	let messages: [any MessageProtocol]
	
	init(currentUser: User, messages: [any MessageProtocol]) {
		self.currentUser = currentUser
		self.messages = messages
	}
	
	var body: some View {
		ScrollView {
			LazyVStack {
				ForEach(messages, id: \.id) { message in
					HStack {
						// If the message is mine, push it to the right
						if isMessageMine(message) {
							Spacer()
						}
						MessageRow(currentUser: currentUser, message: message)
						// If message is not mine, then send it to the far left
						if isMessageMine(message) == false {
							Spacer()
						}
					}
				}
			}
		}
	}
	
	func isMessageMine(_ message: any MessageProtocol) -> Bool {
		currentUser.id == message.sender.id
	}
}

struct MessageRow: View {
	let currentUser: User
	let message: any MessageProtocol
	var body: some View {
		VStack {
			switch message.content {
			case .text(let text):
				Text(text)
					.padding()
					.background(Color.gray.opacity(0.2))
					.clipShape(.rect(cornerRadius: 16))
			case .images(let images):
				imageView(images)
			case .files:
				// TODO: Implement the view later
				EmptyView()
			}
		}
	}
	
	@ViewBuilder
	func imageView(_ urls: [String]) -> some View {
		if urls.isEmpty {
			EmptyView()
		} else if urls.count == 1, let stringUrl = urls.first, let url = URL(string: stringUrl) {
			// Single Image
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.gray.opacity(0.3))
				.frame(width: 200, height: 200)
				.overlay(
					// TODO: Use Async image to load the image
					AsyncImage(url: url)
				)
		} else {
			// Multiple images
			LazyVGrid(columns: [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)], spacing: 2) {
				ForEach(urls, id: \.self) { url in
					RoundedRectangle(cornerRadius: 8)
						.fill(Color.gray.opacity(0.3))
						.frame(height: 95)
						.overlay(
							Image(systemName: "photo")
								.font(.system(size: 20))
								.foregroundColor(.gray)
						)
				}
			}
			.frame(width: 200)
		}
	}
}

#Preview("Message Row") {
	MessageRow(
		currentUser: User(id: "me", name: "Nicolas", avator: nil),
		message: Message.mocks.first!
	)
}

#Preview("Chat") {
	ChatDetailsView(
		currentUser: User(id: "me", name: "Nicolas", avator: nil),
		chat: Chat.mocks.first!
	)
}
