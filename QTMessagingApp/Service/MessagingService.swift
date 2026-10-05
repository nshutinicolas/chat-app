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

private struct CreateChatRequest: Encodable {
	let participantIDs: [UUID]
	let title: String?
}

private struct CreateMessageRequest: Encodable {
	let type: String
	let text: String
	let documents: [String]? = nil
	let replyTo: UUID? = nil
}

private struct ServerUser: Decodable {
	let id: UUID
	let username: String

	var user: User { User(id: id.uuidString, name: username, avator: nil) }
}

private struct ServerDocument: Decodable {
	let url: String
}

private struct ServerMessage: Decodable {
	let id: UUID
	let sender: ServerUser
	let type: String
	let text: String?
	let documents: [ServerDocument]
	let isRead: Bool
	let createdAt: Date?

	var message: Message {
		let content: MessageContent = type == "document" ? .docs(documents.map(\.url)) : .text(text ?? "")
		return Message(
			id: id.uuidString,
			content: content,
			sender: sender.user,
			date: createdAt ?? .distantPast,
			isRead: isRead,
			status: .sent
		)
	}
}

private struct ServerChat: Decodable {
	let id: UUID
	let participants: [ServerUser]
	let latestMessage: ServerMessage?

	var chat: Chat {
		Chat(id: id.uuidString, latestMessage: latestMessage?.message, participants: participants.map(\.user))
	}
}

private struct SocketType: Decodable { let type: String }
private struct SocketEnvelope<Payload: Decodable>: Decodable { let data: Payload }

enum ChatListUpdate {
	case connected
	case disconnected
	case chats([Chat])
	case failure(String)
}

enum ChatMessageUpdate {
	case connected
	case disconnected
	case messages([any MessageProtocol])
	case message(any MessageProtocol)
	case failure(String)
}

class MessagingService {
	nonisolated static let shared = MessagingService()
	
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

	func createChat(creatorID: String, participantID: String) async throws -> Chat {
		guard let creatorID = UUID(uuidString: creatorID), let participantID = UUID(uuidString: participantID) else {
			throw ServiceAPIError(message: "Enter a valid user ID.")
		}
		let response: ServerChat = try await request(
			"chats",
			method: .post,
			queryItems: [URLQueryItem(name: "user_id", value: creatorID.uuidString)],
			body: JSONEncoder().encode(CreateChatRequest(participantIDs: [participantID], title: nil))
		)
		return response.chat
	}

	// MARK: - HTTP

	private func request<Response: Decodable>(
		_ path: String,
		method: HTTPMethod = .get,
		queryItems: [URLQueryItem] = [],
		body: Data? = nil
	) async throws -> Response {
		guard var components = URLComponents(
			url: AppConfig.baseURL.appendingPathComponent(path),
			resolvingAgainstBaseURL: false
		) else {
			throw ServiceAPIError(message: "The server endpoint is invalid.")
		}
		components.queryItems = queryItems.isEmpty ? nil : queryItems
		guard let url = components.url else {
			throw ServiceAPIError(message: "The server endpoint is invalid.")
		}
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
			return try makeDecoder().decode(Response.self, from: data)
		} catch {
			throw ServiceAPIError(message: "Could not read the server response. (\(error.localizedDescription))")
		}
	}

	private enum HTTPMethod: String {
		case get = "GET"
		case post = "POST"
	}

	private func makeDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}
}

// Chat
extension MessagingService: ChatListServiceProtocol {
	func loadChats(for userID: String) -> AsyncStream<ChatListUpdate> {
		AsyncStream { continuation in
			guard let userID = UUID(uuidString: userID),
				  let url = AppConfig.socketURL(path: "chats/messages", userID: userID)
			else {
				continuation.yield(.failure("Your saved user ID is invalid."))
				continuation.finish()
				return
			}

			let task = Task {
				var reconnectDelay = 1.0
				while !Task.isCancelled {
					let socket = URLSession.shared.webSocketTask(with: url)
					socket.resume()
					var didConnect = false

					do {
						while !Task.isCancelled {
							let frame = try await socket.receive()
							if !didConnect {
								didConnect = true
								reconnectDelay = 1
								continuation.yield(.connected)
							}
							if let update = chatListUpdate(from: frame) {
								continuation.yield(update)
							}
						}
					} catch {
						if !Task.isCancelled { continuation.yield(.disconnected) }
					}

					socket.cancel(with: .goingAway, reason: nil)
					guard !Task.isCancelled else { break }
					try? await Task.sleep(for: .seconds(reconnectDelay))
					reconnectDelay = min(reconnectDelay * 2, 15)
				}
				continuation.finish()
			}
			continuation.onTermination = { _ in task.cancel() }
		}
	}

	private func chatListUpdate(from frame: URLSessionWebSocketTask.Message) -> ChatListUpdate? {
		let data: Data
		switch frame {
		case .string(let text): data = Data(text.utf8)
		case .data(let raw): data = raw
		@unknown default: return nil
		}
		guard let type = try? makeDecoder().decode(SocketType.self, from: data).type else { return nil }
		switch type {
		case "chats":
			guard let response = try? makeDecoder().decode(SocketEnvelope<[ServerChat]>.self, from: data) else { return nil }
			return .chats(response.data.map(\.chat))
		case "error":
			guard let response = try? makeDecoder().decode(SocketEnvelope<String>.self, from: data) else { return nil }
			return .failure(response.data)
		default:
			return nil
		}
	}
}

extension MessagingService: ChatDetailsServiceProtocol {
	
	func sendMessage(_ message: any MessageProtocol) async throws {
		// Encrypt the data before sending
		
	}
	
	func loadChatMessages(forChat chatID: String, userID: String) -> AsyncStream<ChatMessageUpdate> {
		AsyncStream { continuation in
			guard let chatID = UUID(uuidString: chatID),
				  let userID = UUID(uuidString: userID),
				  let url = AppConfig.socketURL(path: "chats/messages/\(chatID.uuidString)", userID: userID)
			else {
				continuation.yield(.failure("This conversation is no longer valid."))
				continuation.finish()
				return
			}

			let task = Task {
				var reconnectDelay = 1.0
				while !Task.isCancelled {
					let socket = URLSession.shared.webSocketTask(with: url)
					socket.resume()
					var didConnect = false
					do {
						while !Task.isCancelled {
							let frame = try await socket.receive()
							if !didConnect {
								didConnect = true
								reconnectDelay = 1
								continuation.yield(.connected)
							}
							if let update = chatMessageUpdate(from: frame) {
								continuation.yield(update)
							}
						}
					} catch {
						if !Task.isCancelled { continuation.yield(.disconnected) }
					}
					socket.cancel(with: .goingAway, reason: nil)
					guard !Task.isCancelled else { break }
					try? await Task.sleep(for: .seconds(reconnectDelay))
					reconnectDelay = min(reconnectDelay * 2, 15)
				}
				continuation.finish()
			}
			continuation.onTermination = { _ in task.cancel() }
		}
	}
	
	func sendMessage(text: String, chatID: String, senderID: String) async throws -> any MessageProtocol {
		try await sendTextMessage(text, chatID: chatID, senderID: senderID)
	}
	
	func sendTextMessage(_ text: String, chatID: String, senderID: String) async throws -> any MessageProtocol {
		guard let chatID = UUID(uuidString: chatID), let senderID = UUID(uuidString: senderID) else {
			throw ServiceAPIError(message: "This conversation is no longer valid.")
		}
		let response: ServerMessage = try await request(
			"chats/messages/\(chatID.uuidString)",
			method: .post,
			queryItems: [URLQueryItem(name: "user_id", value: senderID.uuidString)],
			body: JSONEncoder().encode(CreateMessageRequest(type: "text", text: text))
		)
		return response.message
	}
	
	func uploadDocuments(_ data: [Data]) async throws -> [String] {
		// Connect to service
		// For test only
		return []
	}

	private func chatMessageUpdate(from frame: URLSessionWebSocketTask.Message) -> ChatMessageUpdate? {
		let data: Data
		switch frame {
		case .string(let text): data = Data(text.utf8)
		case .data(let raw): data = raw
		@unknown default: return nil
		}
		guard let type = try? makeDecoder().decode(SocketType.self, from: data).type else { return nil }
		switch type {
		case "messages":
			guard let response = try? makeDecoder().decode(SocketEnvelope<[ServerMessage]>.self, from: data) else { return nil }
			return .messages(response.data.map(\.message))
		case "message":
			guard let response = try? makeDecoder().decode(SocketEnvelope<ServerMessage>.self, from: data) else { return nil }
			return .message(response.data.message)
		case "error":
			guard let response = try? makeDecoder().decode(SocketEnvelope<String>.self, from: data) else { return nil }
			return .failure(response.data)
		default:
			return nil
		}
	}
}
