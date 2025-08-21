//
//  Other.swift
//  EduCalm
//
//  Created by Adon Omeri on 20/8/2025.
//

import SwiftUI

extension Color {
	static let predefined: [Color] = [
		.red, .orange, .yellow, .green, .mint,
		.teal, .cyan, .blue, .indigo, .purple,
		.pink
	]

	static var random: Color {
		predefined.randomElement()!
	}
}
