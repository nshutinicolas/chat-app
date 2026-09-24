//
//  EncryptionService.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

protocol MessageEncryptionService {
	func encrypt(
		_ plaintext: String,
		conversation: Messa
	) throws -> EncryptedMessage
	
	func decrypt(
		_ message: EncryptedMessage,
		conversation: Conversation
	) throws -> String
}
