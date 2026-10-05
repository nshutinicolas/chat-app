//
//  ChatListViewModel.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

protocol ChatListServiceProtocol {
	func loadChats(for userID: String) -> AsyncStream<ChatListUpdate>
}

@MainActor
@Observable
class ChatListViewModel {
	private let service: ChatListServiceProtocol
	
	var displayState: DisplayState = .loading
	var chats: [any ChatProtocol] = []
	
	init(service: ChatListServiceProtocol = MessagingService.shared) {
		self.service = service
	}
	
	func run(for userID: String) async {
		for await update in service.loadChats(for: userID) {
			switch update {
			case .connected:
				if case .error = displayState { displayState = .loading }
			case .disconnected:
				if chats.isEmpty { displayState = .loading }
			case .chats(let chats):
				self.chats = chats.sorted { ($0.latestMessage?.date ?? .distantPast) > ($1.latestMessage?.date ?? .distantPast) }
				displayState = chats.isEmpty ? .empty : .complete
			case .failure(let message):
				displayState = .error(message)
			}
		}
	}
	
	enum DisplayState: Equatable {
		case loading, empty, complete, error(String)
	}
}
