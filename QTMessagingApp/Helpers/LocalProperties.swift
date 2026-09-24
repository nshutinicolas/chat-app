//
//  LocalProperties.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

@propertyWrapper
struct LocalProperties<Value> {
	private let userDefault = UserDefaults.standard
	let key: Key
	
	init(_ key: Key) {
		self.key = key
	}
	
	var wrappedValue: Value? {
		get {
			getValue(for: key)
		} nonmutating set {
			setValue(newValue, for: key)
		}
	}
}

private extension LocalProperties {
	func getValue<T>(for key: Key) -> T? {
		userDefault.object(forKey: key.rawValue) as? T
	}
	
	func setValue(_ value: Any?, for key: Key) {
		userDefault.set(value, forKey: key.rawValue)
	}
}

extension LocalProperties {
	enum Key: String {
		case userName
		case userId
	}
}
