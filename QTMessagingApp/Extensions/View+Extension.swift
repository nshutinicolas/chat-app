//
//  View+Extension.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 25/09/2026.
//

import SwiftUI

extension View {
	func roundedBorder(
		_ radius: CGFloat = 8,
		color: Color = .gray.opacity(0.5),
		fill: Color = Color(uiColor: .systemBackground),
		lineWidth: CGFloat = 1
	) -> some View {
		self
			.overlay {
				RoundedRectangle(cornerRadius: radius)
					.stroke(color, lineWidth: lineWidth)
			}
			.background(fill)
			.clipShape(.rect(cornerRadius: radius))
	}
	
	func roundedBorder<S>(
		for shape: S,
		color: Color = .gray.opacity(0.5),
		fill: Color = Color.clear,
		lineWidth: CGFloat = 1
	) -> some View where S: Shape {
		self
			.contentShape(shape)
			.background(fill)
			.clipShape(shape)
			.overlay {
				shape.stroke(color, lineWidth: lineWidth)
			}
	}
}
