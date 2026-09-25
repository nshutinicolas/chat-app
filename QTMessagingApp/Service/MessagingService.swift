//
//  MessagingService.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation
import CryptoKit

enum ServiceError: Error {
	case invalidData
}

class MessagingService {
	static let shared = MessagingService()
	
	private init() { }
}

// Chat
extension MessagingService: ChatListServiceProtocol {
	func loadChats() -> AsyncThrowingStream<any ChatProtocol, Error> {
		AsyncThrowingStream { continuation in
			// Do the service work from the backend
			// For testing only
			Task {
				for chat in Chat.mocks {
					continuation.yield(chat)
					try? await Task.sleep(for: .seconds(0.5))
				}
			}
		}
	}
}

extension MessagingService: ChatDetailsServiceProtocol {
	func loadChatMessages(forChat chatId: String) -> AsyncThrowingStream<any MessageProtocol, Error> {
		AsyncThrowingStream { continuation in
			// Do the service work from here
			// For Testing purpose only
			Task {
				for message in Message.mocks {
					continuation.yield(message)
					try? await Task.sleep(for: .seconds(0.3))
				}
			}
		}
	}
	
	func sendMessage(_ message: any MessageProtocol) async throws {
		// Encrypt the data before sending
		
	}
	
	func uploadDocuments(_ data: [Data]) async throws -> [String] {
		// Connect to service
		// For test only
		return []
	}
}
