//
//  ContentView.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import SwiftUI

struct ContentView: View {
	@Environment(InitialAppState.self) private var initialState
	init() { }
	
    var body: some View {
		NavigationStack {
			switch initialState.appLoadingState {
			case .loading:
				ProgressView("App loading...")
			case .loaded:
				if let userInfo = initialState.userInfo {
					ChatListView(currentUser: userInfo)
				} else {
					UserNameView()
				}
			}
		}
    }
}

#Preview {
    ContentView()
}
