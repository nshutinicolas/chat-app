//
//  CVhatListViewModel.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

protocol ChatListServiceProtocol {
	func loadChats() -> AsyncThrowingStream<[any ChatProtocol], Error>
}

@Observable
class CVhatListViewModel {
	private let service: ChatListServiceProtocol
	
	init(service: ChatListServiceProtocol = MessagingService.shared) {
		self.service = service
	}
	
}

