	//
	//  HomeTab.swift
	//  Educalm
	//
	//  Created by Adon Omeri on 19/8/2025.
	//


import SwiftUI
import ColorfulX
import Defaults

struct HomeTab: View {
	@State var colourfulPreset = ColorfulPreset.lavandula
	
	var body: some View {
		ZStack {
			ColorfulView(color: $colourfulPreset)
				.opacity(0.4)
				.ignoresSafeArea()
			
			NavigationStack {
				ScrollView {
					VStack(spacing: 24) {
						Text("Welcome to EduCalm")
							.font(.largeTitle)
							.fontWeight(.bold)
							.padding()
						
						Text("Your educational wellness companion")
							.font(.title2)
							.foregroundColor(.secondary)
						
							// Quick actions or overview content
						LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
							QuickActionCard(
								title: "Resources",
								icon: "doc.text",
								description: "Access mental health resources"
							)
							
							QuickActionCard(
								title: "Chat",
								icon: "bubble.left.and.bubble.right",
								description: "Talk to AI assistant"
							)
							
							QuickActionCard(
								title: "Wellness",
								icon: "heart",
								description: "Track your wellbeing"
							)
							
							QuickActionCard(
								title: "Support",
								icon: "hands.and.sparkles",
								description: "Get help when needed"
							)
                            QuickActionCard(
                                title: "Noise",
                                icon: "hands.and.sparkles",
                                description: "Calming noise player"
                            )
						}
						.padding()
					}
				}
				.scrollContentBackground(.hidden)
				.background(Color.clear)
				.navigationTitle("Home")
			}
		}
	}
}

struct QuickActionCard: View {
	let title: String
	let icon: String
	let description: String
	
	var body: some View {
		VStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 30))
				.foregroundColor(.blue)
			
			Text(title)
				.font(.headline)
				.fontWeight(.semibold)
			
			Text(description)
				.font(.caption)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 120)
		.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
	}
}

#Preview {
	HomeTab()
}
