//
//  ChatDetailsViewModel.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

protocol ChatDetailsServiceProtocol {
	func loadChatMessages(forChat chatId: String) -> AsyncThrowingStream<any MessageProtocol, Error>
	func sendMessage(_ message: MessageContent) async throws
}

@Observable
class ChatDetailsViewModel {
	private let service: ChatDetailsServiceProtocol
	private let chat: any ChatProtocol
	
	var loadingState: ViewLoadingState = .loading
	var messages: [any MessageProtocol] = []
	
	init(chat: any ChatProtocol, service: ChatDetailsServiceProtocol = MessagingService.shared) {
		self.service = service
		self.chat = chat
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
			do {
				for try await chat in self.service.loadChatMessages(forChat: chatId) {
					var previousMessages = self.messages
					previousMessages.append(chat)
					self.messages = previousMessages.sorted { $0.date < $1.date }
					if self.loadingState != .loaded {
						self.loadingState = .loaded
					}
				}
			} catch {
				self.loadingState = .error
				print(error)
				tasks[.fetchChatMessages] = nil
			}
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
}

