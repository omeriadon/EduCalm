//
//  Introsheet.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import ColorfulX
import SwiftUI

let heroGradient = LinearGradient(
	colors: [.purple, .blue],
	startPoint: .topLeading,
	endPoint: .bottomTrailing
)

struct IntroSheet: View {
	@Binding var hasCompletedIntro: Bool

	@State var showQuestions: Bool = false

	@State var colourfulPreset = ColorfulPreset.jelly

	var body: some View {
		GeometryReader { proxy in
			ZStack {
				ColorfulView(color: $colourfulPreset)
					.animation(.easeInOut(duration: 4), value: showQuestions)
					.opacity(showQuestions ? 0.3 : 0.5)
				NavigationStack {
					if !showQuestions {
						VStack {
							Group {
								Text("Welcome to ")
									.fontWeight(.light)
								+
								Text("Educalm")
									.foregroundStyle(heroGradient)
									.fontWeight(.black)
							}
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
									showQuestions = true
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

					} else {
						ScrollView(.horizontal) {
							LazyHStack(spacing: 0) {
								ForEach(0 ..< 5) { i in
									Color(hue: Double(i) / 5, saturation: 0.8, brightness: 0.9)
										.frame(width: proxy.size.width)
								}
							}
							.scrollTargetLayout()
						}
						.scrollTargetBehavior(.paging)
					}
				}
			}

		}
		.interactiveDismissDisabled(true)
		.frame(
			minWidth: 320, idealWidth: 500, maxWidth: 600,
			minHeight: 500, idealHeight: 700, maxHeight: 800
		)
	}
}

#Preview {
	IntroSheet(hasCompletedIntro: .constant(false))
		.tint(.purple)
}
