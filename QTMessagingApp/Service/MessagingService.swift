//
//  MessagingService.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

class MessagingService {
	static let shared = MessagingService()
	
	private init() { }
}

// Chat
extension MessagingService: ChatListServiceProtocol {
	func loadChats() -> AsyncThrowingStream<[any ChatProtocol], Error> {
		AsyncThrowingStream { continuation in
			// Do the service work from the backend
		}
	}
}

extension MessagingService: ChatDetailsServiceProtocol {
	func loadChatMessages(forChat chatId: String) -> AsyncThrowingStream<[any MessageProtocol], Error> {
		AsyncThrowingStream { continuation in
			// Do the service work from here
		}
	}
	
	func sendMessage(_ message: MessageContent) async throws {
		// Do the encryption and the message sending
	}
}
