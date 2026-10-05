//
//  UserNameView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct UserNameView: View {
	@Environment(InitialAppState.self) private var initialAppState
	@AppStorage(AppConfig.serverURLKey) private var serverURL = AppConfig.defaultServerURL
	@State private var viewModel = ViewModel()
	
	init() { }
	
    var body: some View {
		@Bindable var viewModel = viewModel
		VStack(spacing: 12) {
			Text("Welcome to Chat")
				.font(.largeTitle)
				.padding(.bottom)
			VStack(alignment: .leading) {
				Text("To get started, let us know who you are")
				Text("Find something unique that you are happy with")
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.fixedSize(horizontal: false, vertical: true)
			TextField("Enter your name", text: $viewModel.username)
				.font(.body)
				.padding(.vertical, 12)
				.padding(.horizontal, 8)
				.overlay {
					RoundedRectangle(cornerRadius: 12)
						.stroke(Color.gray, lineWidth: 1)
				}
				.background()
				.clipShape(.rect(cornerRadius: 12))
			VStack(alignment: .leading, spacing: 6) {
				Text("Server endpoint")
					.font(.caption)
					.foregroundStyle(.secondary)
				TextField("http://localhost:8080", text: $serverURL)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
					.keyboardType(.URL)
					.font(.body)
					.padding(.vertical, 12)
					.padding(.horizontal, 8)
					.overlay {
						RoundedRectangle(cornerRadius: 12)
							.stroke(Color.gray, lineWidth: 1)
					}
			}
			if let errorMessage = viewModel.errorMessage {
				Text(errorMessage)
					.font(.footnote)
					.foregroundStyle(.red)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			Button("Confirm") {
				Task {
					if let user = await viewModel.createUser(serverURL: serverURL) {
						initialAppState.updateUserInfo(with: user)
					}
				}
			}
			.buttonStyle(.plain)
			.foregroundStyle(.white)
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color.blue)
			.clipShape(.capsule)
			.disabled(!viewModel.canCreateUser)
			.overlay {
				if viewModel.isCreatingUser { ProgressView().tint(.white) }
			}
		}
		.padding()
    }
}

extension UserNameView {
	@MainActor
	@Observable
	final class ViewModel {
		private let service = MessagingService.shared
		var username = ""
		private(set) var isCreatingUser = false
		private(set) var errorMessage: String?
		
		var canCreateUser: Bool {
			(3...32).contains(username.trimmingCharacters(in: .whitespacesAndNewlines).count) && !isCreatingUser
		}
		
		/// Validates input and delegates account creation to the shared service.
		func createUser(serverURL: String) async -> User? {
			let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
			guard (3...32).contains(username.count) else {
				errorMessage = "Your name must be between 3 and 32 characters."
				return nil
			}
			guard let endpoint = URL(string: serverURL), endpoint.scheme == "http" || endpoint.scheme == "https" else {
				errorMessage = "Enter a valid http:// or https:// server endpoint."
				return nil
			}
			
			isCreatingUser = true
			errorMessage = nil
			defer { isCreatingUser = false }
			do {
				return try await service.createUser(username: username)
			} catch {
				errorMessage = error.localizedDescription
				return nil
			}
		}
	}
}

#Preview {
	UserNameView()
}

// Local storage of the user info
import SwiftData
@Model
class UserInfo {
	var name: String
	var id: String
	var avator: String?
	
	init(name: String, id: String, avator: String? = nil) {
		self.name = name
		self.id = id
		self.avator = avator
	}
}
