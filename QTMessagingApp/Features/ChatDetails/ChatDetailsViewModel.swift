//
//  ChatDetailsViewModel.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import PhotosUI
import SwiftUI

protocol ChatDetailsServiceProtocol {
	/// Load chat messages based on a chat id
	/// - Parameters:
	///  - chatId: String representation of the chat id whose messages are to be fetched
	///  - userId: Current userId that connect to the user specific websocket
	/// - Returns `AsyncStream` for ChatMessageUpdate
	func loadChatMessages(forChat chatID: String, userID: String) -> AsyncStream<ChatMessageUpdate>
	/// Sending messages of different content type
	/// - Parameter message: `MessageProtocol`
	func sendMessage(_ message: any MessageProtocol) async throws
	/// Sending Text message
	/// - Parameters:
	///  - text: text message of string type
	///  - chatID: chat id being replied to
	///  - senderID: current user id
	func sendTextMessage(_ text: String, chatID: String, senderID: String) async throws -> any MessageProtocol
	/// Uploading images, file documents sent in the message before they are saved to the DB
	/// - Parameter data: Data representation of the files being uploaded
	/// - Returns string represantaion of the image location on the server
	func uploadDocuments(_ data: [Data]) async throws -> [String]
}

@Observable
class ChatDetailsViewModel {
	private let service: ChatDetailsServiceProtocol
	private let chat: any ChatProtocol
	
	var loadingState: ViewLoadingState = .loading
	var messages: [any MessageProtocol] = []
	// Textfield
	var textFieldText = ""
	// Image selection
	var selectedImages = [PhotosPickerItem]()
	var selectedImagesState: ImageLoadState = .empty
	// User
	@ObservationIgnored var currentUser: User
	// Reply to
	var replyTo: (any MessageProtocol)?
	
	init(
		chat: any ChatProtocol,
		currentUser: User,
		service: ChatDetailsServiceProtocol = MessagingService.shared
	) {
		self.service = service
		self.chat = chat
		self.currentUser = currentUser
		fetchChatMessages(chatId: chat.id)
	}
	deinit {
		tasks.forEach { $0.value.cancel() }
	}
	
	// Task
	private var tasks: [Tasks: Task<Void, Never>] = [:]
	
	func fetchChatMessages(chatId: String) {
		guard tasks[.fetchChatMessages] == nil else { return }
		tasks[.fetchChatMessages] = Task { @MainActor [weak self] in
			guard let self else { return }
			self.loadingState = .loading
			for await chat in self.service.loadChatMessages(forChat: chatId, userID: currentUser.id) {
				upsertMessages(with: chat)
			}
		}
	}
	
	func sendMessage() {
		guard tasks[.sendMessage] == nil else { return }
		tasks[.sendMessage] = Task { @MainActor [weak self] in
			guard let self else { return }
			// Clear content related to the attempted send message
			clearFields()
			// Send messages in sequence
			// First start with files
			if selectedImages.isEmpty == false {
				do {
					// For Image upload, first upload the images and get the urls
					let imageData = await selectedImagesConversion()
					let urlStrings = try await self.service.uploadDocuments(imageData)
					// Then use the urls to create data
					let message = Message(
						id: UUID().uuidString,
						content: .docs(urlStrings),
						sender: currentUser,
						date: .now,
						isRead: false,
						status: .sending,
						replyTo: self.replyTo
					)
					try await self.service.sendMessage(message)
				} catch {
					print("🚨Failed to save message: \(error)")
				}
			}
			// Sending text message
			if textFieldText.trimmingCharacters(in: CharacterSet(charactersIn: " ")).isEmpty == false {
				/**TODO: Uncomment when supporting multiple message types
				let message = Message(
					id: UUID().uuidString,
					content: .text(textFieldText),
					sender: currentUser,
					date: .now,
					isRead: false,
					status: .sending,
					replyTo: self.replyTo
				)
				 */
				do {
					let message = try await self.service.sendTextMessage(textFieldText, chatID: chat.id, senderID: currentUser.id)
					upsertMessages(with: .message(message))
					// Create Message and append it to the queue
					// It will work as a placeholder until it is replaced by the new message
				} catch {
					print("🚨Failed to save message: \(error)")
				}
			}
			tasks[.sendMessage] = nil
		}
	}
	
	@MainActor
	private func upsertMessages(with updates: ChatMessageUpdate) {
		var previousMessages = self.messages
		switch updates {
		case .messages(let messages):
			previousMessages.append(contentsOf: messages)
		case .message(let message):
			previousMessages.append(message)
		default:
			// Can't do anything
			break
		}
		self.messages = previousMessages.sorted { $0.date < $1.date }
		if self.loadingState != .loaded {
			self.loadingState = .loaded
		}
	}
	
	// Image conversion
	func selectedImagesConversion() async -> [Data] {
		let converted = await withTaskGroup(of: Data?.self) { group in
			for image in selectedImages {
				group.addTask {
					try? await image.loadTransferable(type: Data.self)
				}
			}
			var results = [Data?]()
			for await data in group {
				results.append(data)
			}
			return results
		}
		return converted.compactMap(\.self)
	}
	
	func clearFields() {
		Task {
			try? await Task.sleep(for: .seconds(1))
			textFieldText = ""
			selectedImages = []
			selectedImagesState = .empty
		}
	}
	
	enum ViewLoadingState: Equatable {
		case loading
		case loaded
		case error
	}
	
	enum Tasks {
		case fetchChatMessages
		case sendMessage
	}
	
	// For Visual state
	enum ImageLoadState: Equatable {
		case loading
		case loaded([Data])
		case empty
	}
}
