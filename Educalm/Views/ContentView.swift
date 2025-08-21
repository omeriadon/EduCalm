//
//  ContentView.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import Defaults
import SwiftUI

struct ContentView: View {
	@Default(.hasCompletedIntro) var hasCompletedIntro

	var body: some View {
		TabView {
			Tab("Home", systemImage: "house") {
				HomeTab()
			}

			Tab("Resources", systemImage: "doc.text") {
				ResourcesTab()
			}

			Tab("Chat", systemImage: "bubble.left.and.bubble.right") {
				ChatTab()
			}
		}
		.sheet(isPresented: .constant(!hasCompletedIntro)) {
			IntroSheet(hasCompletedIntro: $hasCompletedIntro)
		}
	}
}

#Preview { ContentView() }
