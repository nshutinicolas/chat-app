//
//  ChatDetailsViewModel.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

protocol ChatDetailsServiceProtocol {
	func loadChatMessages(forChat chatId: String) -> AsyncThrowingStream<[any MessageProtocol], Error>
	func sendMessage(_ message: MessageContent) async throws
}

@Observable
class ChatDetailsViewModel {
	private let service: ChatDetailsServiceProtocol
	
	init(service: ChatDetailsServiceProtocol = MessagingService.shared) {
		self.service = service
	}
}

