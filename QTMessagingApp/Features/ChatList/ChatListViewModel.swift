//
//  ChatListViewModel.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

protocol ChatListServiceProtocol {
	func loadChats() -> AsyncThrowingStream<any ChatProtocol, Error>
}

@Observable
class ChatListViewModel {
	private let service: ChatListServiceProtocol
	
	var displayState: DisplayState = .loading
	var chats: [any ChatProtocol] = []
	
	init(service: ChatListServiceProtocol = MessagingService.shared) {
		self.service = service
	}
	
	func fetchChats() {
		Task { @MainActor [weak self] in
			guard let self else { return }
			do {
				self.displayState = .loading
				for try await chat in self.service.loadChats() {
					var existing = self.chats
					existing.append(chat)
					self.chats = existing.sorted{ $0.latestMessage.date > $1.latestMessage.date }
					self.displayState = .complete
				}
			} catch {
				print(error)
			}
		}
	}
	
	enum DisplayState: Equatable {
		case loading, complete, error
	}
}

