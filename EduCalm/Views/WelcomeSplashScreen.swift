//
//  WelcomeSplashScreen.swift
//  EduCalm
//
//  Created by Adon Omeri on 24/8/2025.
//

import SwiftUI

struct WelcomeSplashScreen: View {
	let onGetStarted: () -> Void
	
	var body: some View {
		VStack {
			Text("Welcome to \(Text("EduCalm").foregroundStyle(heroGradient).fontWeight(.black))")
				.font(.largeTitle)
				.fontWeight(.bold)
			
			Text("Your educational wellness companion")
				.foregroundStyle(heroGradient)
				.font(.title2)
			
			Spacer()
			
			HStack {
				Image(systemName: "graduationcap.fill")
					.font(.system(size: 90))
				
				Image(systemName: "cross.fill")
					.font(.system(size: 90))
			}
			.foregroundStyle(heroGradient)
			
			Text("Learn, grow, and stay calm with personalized educational resources, mindfulness tools, and more.")
				.multilineTextAlignment(.center)
				.padding(.horizontal)
			
			Spacer()
			
			Button {
				withAnimation {
					onGetStarted()
				}
			} label: {
				Label("Get Started", systemImage: "arrow.right")
					.font(.title)
			}
			.controlSize(.extraLarge)
			.buttonStyle(.glassProminent)
		}
		.padding()
		.scrollBounceBehavior(.basedOnSize)
	}
}
