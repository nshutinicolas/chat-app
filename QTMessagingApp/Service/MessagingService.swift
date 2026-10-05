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

private struct ServiceAPIError: LocalizedError {
	let message: String

	var errorDescription: String? { message }
}

private struct ServerError: Decodable {
	let reason: String
}

private struct CreateUserRequest: Encodable {
	let username: String
}

private struct UserResponse: Decodable {
	let id: UUID
	let username: String
}

class MessagingService {
	static let shared = MessagingService()
	
	private init() { }

	// MARK: - Accounts

	/// Creates an account in Vapor's `users` table and returns its server-issued ID.
	func createUser(username: String) async throws -> User {
		let response: UserResponse = try await request(
			"users",
			method: .post,
			body: JSONEncoder().encode(CreateUserRequest(username: username))
		)
		return User(id: response.id.uuidString, name: response.username, avator: nil)
	}

	// MARK: - HTTP

	private func request<Response: Decodable>(
		_ path: String,
		method: HTTPMethod = .get,
		body: Data? = nil
	) async throws -> Response {
		let url = AppConfig.baseURL.appendingPathComponent(path)
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.timeoutInterval = 15
		if let body {
			request.httpBody = body
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		}

		let data: Data
		let response: URLResponse
		do {
			(data, response) = try await URLSession.shared.data(for: request)
		} catch {
			throw ServiceAPIError(message: "Can’t reach the server. Check that it is running and the address is correct. (\(error.localizedDescription))")
		}

		guard let httpResponse = response as? HTTPURLResponse else {
			throw ServiceAPIError(message: "The server returned an invalid response.")
		}
		guard (200..<300).contains(httpResponse.statusCode) else {
			let reason = try? JSONDecoder().decode(ServerError.self, from: data).reason
			throw ServiceAPIError(message: reason ?? "Server error (\(httpResponse.statusCode)).")
		}

		do {
			return try JSONDecoder().decode(Response.self, from: data)
		} catch {
			throw ServiceAPIError(message: "Could not read the server response. (\(error.localizedDescription))")
		}
	}

	private enum HTTPMethod: String {
		case get = "GET"
		case post = "POST"
	}
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
