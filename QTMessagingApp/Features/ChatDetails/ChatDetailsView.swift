//
//  ChatDetailsView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import PhotosUI
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
		self._viewModel = State(wrappedValue: ChatDetailsViewModel(chat: chat, currentUser: currentUser))
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
				HStack(alignment: .bottom) {
					Button("", systemImage: "plus") {
						withAnimation {
							openDocSelector.toggle()
						}
					}
					.buttonStyle(.plain)
					.foregroundStyle(.secondary)
					.labelStyle(.iconOnly)
					.font(.title3.weight(.semibold))
					.padding(8)
					.roundedBorder(for: .circle, lineWidth: .zero)
					VStack {
						if viewModel.selectedImages.isEmpty == false {
							selectedImagesView()
							Divider()
						}
						HStack(alignment: .bottom) {
							TextField("Enter a message", text: $viewModel.textFieldText)
								.focused($textfieldFocused)
								.font(.body)
								.lineLimit(1...6)
								.fixedSize(horizontal: false, vertical: true)
							Button("Send", systemImage: "paperplane.fill") {
								viewModel.sendMessage()
							}
							.labelStyle(.iconOnly)
						}
					}
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
					documentSelectors()
				}
			}
			.padding(.vertical, 8)
			.background()
		}
		.padding()
		.onChange(of: textfieldFocused) { oldValue, newValue in
			guard oldValue != newValue, newValue == true else { return }
			withAnimation {
				openDocSelector = false
			}
		}
		.task(id: viewModel.selectedImages) {
			let converted = await viewModel.selectedImagesConversion()
			viewModel.selectedImagesState = .loaded(converted)
		}
		.navigationTitle(chat.otherUser(not: currentUser)?.name ?? "")
		.navigationBarTitleDisplayMode(.inline)
    }
	
	@ViewBuilder
	private func selectedImagesView() -> some View {
		switch viewModel.selectedImagesState {
		case .loading:
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.gray.opacity(0.2), lineWidth: 1)
				.frame(width: 100, height: 100)
				.overlay {
					ProgressView()
						.controlSize(.large)
				}
				.clipShape(.rect(cornerRadius: 12))
		case .loaded(let imageData):
			ScrollView(.horizontal) {
				HStack {
					ForEach(0..<imageData.count, id: \.self) { index in
						if let uiImage = UIImage(data: imageData[index]) {
							Image(uiImage: uiImage)
								.resizable()
								.scaledToFit()
								.frame(height: 100)
								.overlay(alignment: .topTrailing) {
									Button("delete", systemImage: "xmark") {
										var loadedImageData = [Data]()
										if case let .loaded(data) = viewModel.selectedImagesState {
											loadedImageData = data
											loadedImageData.remove(at: index)
											withAnimation {
												viewModel.selectedImagesState = .loaded(loadedImageData)
												viewModel.selectedImages.remove(at: index)
											}
										}
									}
									.font(.footnote)
									.fontWeight(.bold)
									.buttonStyle(.plain)
									.labelStyle(.iconOnly)
									.foregroundStyle(.white)
									.padding(4)
									.roundedBorder(for: .circle, color: .white, fill: Color.gray.opacity(0.8), lineWidth: 2)
									.padding(4)
								}
								.roundedBorder(12, lineWidth: 0)
						}
					}
				}
			}
		case .empty:
			EmptyView()
		}
	}
	
	@ViewBuilder
	private func documentSelectors() -> some View {
		HStack(spacing: 12) {
			selectDocumentButton(icon: "camera", text: "Camera") {
				
			}
			PhotosPicker(
				selection: $viewModel.selectedImages,
				maxSelectionCount: 4,
				matching: .images
			) {
				VStack {
					Image(systemName: "photo")
						.padding()
						.background(Color.gray.opacity(0.2))
						.clipShape(.circle)
					Text("Photos")
				}
				.background()
			}
			.buttonStyle(.plain)
			selectDocumentButton(icon: "doc", text: "Document") {
				
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	@ViewBuilder
	private func selectDocumentButton(icon: String, text: String, _ action: @escaping () -> Void) -> some View {
		Button {
			action()
		} label: {
			VStack {
				Image(systemName: icon)
					.padding()
					.background(Color.gray.opacity(0.2))
					.clipShape(.circle)
				Text(text)
			}
		}
		.buttonStyle(.plain)
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
	private let currentUser: User
	private let message: any MessageProtocol
	
	init(currentUser: User, message: any MessageProtocol) {
		self.currentUser = currentUser
		self.message = message
	}
	var isMessageMine: Bool {
		currentUser.id == message.sender.id
	}
	
	var body: some View {
		HStack {
			VStack(alignment: .trailing, spacing: 4) {
				switch message.content {
				case .text(let text):
					Text(text)
						.padding()
						.foregroundStyle(isMessageMine ? .white : .primary)
						.roundedBorder(16, fill: isMessageMine ? .blue : Color.secondary.opacity(0.3), lineWidth: .zero)
						.background(Color.gray.opacity(0.2))
						.clipShape(.rect(cornerRadius: 16))
				case .docs(let images):
					imageView(images)
				}
				HStack {
					Text(message.date.chatFormatted())
						.font(.caption)
					Group {
						switch message.status {
						case .sending:
							Image(systemName: "arrow.2.circlepath.circle")
								.foregroundStyle(.gray)
						case .failed:
							Image(systemName: "exclamationmark.circle")
								.foregroundStyle(.red)
						case .sent:
							Image(systemName: "checkmark.circle")
								.foregroundStyle(.green)
						}
					}
					.font(.footnote)
				}
			}
			// Resend message indicator
			if message.status == .failed {
				Button {} label: {
					VStack {
						Image(systemName: "arrow.2.circlepath.circle")
						Text("Retry")
					}
					.font(.caption)
				}
				.buttonStyle(.plain)
			}
		}
	}
	
	@ViewBuilder
	func imageView(_ urls: [String]) -> some View {
		if urls.isEmpty {
			EmptyView()
		} else if urls.count == 1, let stringUrl = urls.first {
			// Single Image
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.gray.opacity(0.3))
				.frame(width: 100, height: 100)
				.overlay(
					AsyncImage(url: URL(string: stringUrl)) { phase in
						switch phase {
						case .success(let image):
							image.resizable()
								.scaledToFit()
								.frame(height: 100)
						default:
							Image(systemName: "photo")
								.font(.system(size: 20))
								.foregroundColor(.gray)
						}
					}
				)
		} else {
			// Multiple images
			LazyVGrid(
				columns: [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)],
				spacing: 2
			) {
				ForEach(urls, id: \.self) { url in
					RoundedRectangle(cornerRadius: 8)
						.fill(Color.gray.opacity(0.3))
						.frame(height: 100)
						.overlay(
							AsyncImage(url: URL(string: url)) { phase in
								switch phase {
								case .success(let image):
									image.resizable()
										.scaledToFit()
										.frame(height: 100)
								default:
									Image(systemName: "photo")
										.font(.system(size: 20))
										.foregroundColor(.gray)
								}
							}
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
