	//
	//  ChatTab.swift
	//  EduCalm
	//
	//  Created by Adon Omeri on 19/8/2025.
	//

import SwiftUI
import ColorfulX

struct ChatTab: View {
	var body: some View {
		NavigationStack {
			VStack {
				Text("AI Chat Assistant")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding()

				Text("Start a conversation for mental health support")
					.font(.title3)
					.foregroundColor(.secondary)
					.multilineTextAlignment(.center)
					.padding(.horizontal)

				Spacer()

					// Placeholder chat interface
				VStack(spacing: 16) {
					Image(systemName: "bubble.left.and.bubble.right.fill")
						.font(.system(size: 80))
						.foregroundColor(.blue)

					Text("Chat functionality coming soon...")
						.foregroundColor(.secondary)
						.padding()
						.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
				}

				Spacer()
			}
			.navigationTitle("Chat")
		}
	}
}

#Preview {
	ChatTab()
}

