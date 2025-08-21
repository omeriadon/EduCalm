	//
	//  ChatDetailView.swift
	//  EduCalm
	//
	//  Created by Adon Omeri on 20/8/2025.
	//

import SwiftUI
import ColorfulX

struct ChatDetailView: View {
	@State var colourfulPreset = ColorfulPreset.starry
	
	var body: some View {
		ZStack {
			ColorfulView(color: $colourfulPreset)
				.opacity(0.4)
				.ignoresSafeArea()
			
			VStack {
				Text("AI Chat Assistant")
					.font(.title2)
					.padding()
				
				Text("Start a conversation with our AI assistant for mental health support and guidance.")
					.multilineTextAlignment(.center)
					.padding()
				
				Spacer()
				
					// Placeholder for actual chat implementation
				Text("Chat functionality coming soon...")
					.foregroundColor(.secondary)
					.padding()
					.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
				
				Spacer()
			}
			.navigationTitle("AI Chat")
		}
	}
}
