//
//  UserNameView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct UserNameView: View {
	@Environment(\.modelContext) private var modelContext
	@LocalProperties(.userId) private var userId: String?
	@LocalProperties(.userName) private var userName: String?
	@State private var userNameText = ""
	private let complete: () -> Void
	
	init(_ complete: @escaping () -> Void) {
		self.complete = complete
	}
	
    var body: some View {
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
			TextField("Enter your name", text: $userNameText)
				.font(.body)
				.padding(.vertical, 12)
				.padding(.horizontal, 8)
				.overlay {
					RoundedRectangle(cornerRadius: 12)
						.stroke(Color.gray, lineWidth: 1)
				}
				.background()
				.clipShape(.rect(cornerRadius: 12))
			Button("Confirm") {
				onConfirmUserName()
			}
			.buttonStyle(.plain)
			.foregroundStyle(.white)
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color.blue)
			.clipShape(.capsule)
		}
		.padding()
    }
	
	private func onConfirmUserName() {
		guard userNameText.count > 4 else { return }
		userId = UUID().uuidString
		userName = userNameText
	}
}

#Preview {
	UserNameView { }
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
