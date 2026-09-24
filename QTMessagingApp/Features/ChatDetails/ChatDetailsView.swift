//
//  ChatDetailsView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct ChatDetailsView: View {
	@State private var viewModel: ChatDetailsViewModel
	@State private var openDocSelector = false
	private let currentUser: User
	private let chat: any ChatProtocol
	@FocusState private var textfieldFocused
	
	init(currentUser: User, chat: any ChatProtocol) {
		self.currentUser = currentUser
		self.chat = chat
		self._viewModel = State(wrappedValue: ChatDetailsViewModel(chat: chat))
	}
	
    var body: some View {
		VStack {
			switch viewModel.loadingState {
			case .loading:
				ProgressView("Loading messages")
			case .loaded:
				ChatMessagesView(currentUser: currentUser, messages: viewModel.messages)
			case .error:
				VStack {
					Text("Failed to fetch messages. Please try again later.")
					Button("Reload") { }
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.safeAreaInset(edge: .bottom) {
			VStack {
				HStack {
					Button("", systemImage: "plus") {
						withAnimation {
							openDocSelector.toggle()
						}
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
						.focused($textfieldFocused)
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
				.background()
				if openDocSelector {
					HStack(spacing: 12) {
						Button {} label: {
							VStack {
								Image(systemName: "camera")
								Text("Take Photo")
							}
							.background()
						}
						.buttonStyle(.plain)
						Button {} label: {
							VStack {
								Image(systemName: "photo")
								Text("Gallery")
							}
							.background()
						}
						.buttonStyle(.plain)
						Button {} label: {
							VStack {
								Image(systemName: "doc")
								Text("Document")
							}
							.background()
						}
						.buttonStyle(.plain)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}
		.padding()
		.onChange(of: textfieldFocused) { oldValue, newValue in
			guard oldValue != newValue, newValue == true else { return }
			withAnimation {
				openDocSelector = false
			}
		}
		.navigationTitle(currentUser.name)
//		.navigationBarTitleDisplayMode(.inline)
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
		ScrollViewReader { proxy in
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
						.id(message.id)
					}
				}
			}
			.onAppear {
				scrollToBottom(proxy)
			}
			.onChange(of: messages.count) { _, _ in
				scrollToBottom(proxy)
			}
		}
	}
	
	private func isMessageMine(_ message: any MessageProtocol) -> Bool {
		currentUser.id == message.sender.id
	}
	
	private func scrollToBottom(_ proxy: ScrollViewProxy) {
		withAnimation {
			if let last = messages.last {
				proxy.scrollTo(last.id, anchor: .bottom)
			}
		}
	}
}

struct MessageRow: View {
	let currentUser: User
	let message: any MessageProtocol
	var body: some View {
		VStack(alignment: .trailing, spacing: 4) {
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
			Text(message.date.chatFormatted())
				.font(.caption)
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
