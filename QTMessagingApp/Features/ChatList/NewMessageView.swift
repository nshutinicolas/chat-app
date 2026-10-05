//
//  NewMessageView.swift
//  QTMessagingApp
//

import SwiftUI

struct NewMessageView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var viewModel = ViewModel()

	let currentUser: User
	let onCreated: (Chat) -> Void

	var body: some View {
		@Bindable var viewModel = viewModel
		NavigationStack {
			Form {
				Section {
					Text(currentUser.id)
						.font(.footnote.monospaced())
						.textSelection(.enabled)
				} header: {
					Text("Your user ID")
				} footer: {
					Text("Share this ID so another person can start a conversation with you.")
				}

				Section {
					TextField("Recipient user ID", text: $viewModel.recipientID)
						.font(.footnote.monospaced())
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
				} header: {
					Text("Send a message to")
				} footer: {
					Text("Paste the UUID shown in the other person's app.")
				}

				if let errorMessage = viewModel.errorMessage {
					Section { Text(errorMessage).foregroundStyle(.red) }
				}
			}
			.navigationTitle("New message")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Create") {
						Task {
							if let chat = await viewModel.createChat(for: currentUser.id) {
								dismiss()
								onCreated(chat)
							}
						}
					}
					.disabled(!viewModel.canCreate)
				}
			}
		}
	}
}

extension NewMessageView {
	@MainActor
	@Observable
	final class ViewModel {
		var recipientID = ""
		private(set) var isCreating = false
		private(set) var errorMessage: String?

		var canCreate: Bool {
			UUID(uuidString: recipientID.trimmingCharacters(in: .whitespacesAndNewlines)) != nil && !isCreating
		}

		func createChat(for creatorID: String) async -> Chat? {
			isCreating = true
			errorMessage = nil
			defer { isCreating = false }
			do {
				return try await MessagingService.shared.createChat(
					creatorID: creatorID,
					participantID: recipientID.trimmingCharacters(in: .whitespacesAndNewlines)
				)
			} catch {
				errorMessage = error.localizedDescription
				return nil
			}
		}
	}
}
