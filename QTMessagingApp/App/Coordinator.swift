//
//  Coordinator.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation
import SwiftUI

protocol CoordinatorProtocol {
	func pop()
	func push(_ newPath: any Hashable)
	func popToRoot()
}

@Observable
class Coordinator: CoordinatorProtocol {
	var path = NavigationPath()
	init() { }
	
	func push(_ newPath: any Hashable) {
		path.append(newPath)
	}
	
	func pop() {
		path.removeLast()
	}
	
	func popToRoot() {
		path = NavigationPath()
	}
}
