//
//  ContentView.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import ColorfulX
import Defaults
import SwiftUI

struct ContentView: View {
	@Default(.hasCompletedIntro) var hasCompletedIntro
	@State private var selectedTab: String = "Home"
	@State private var showQuestionsSheet = false
	
	var body: some View {
		TabView(selection: $selectedTab) {
			Tab("Home", systemImage: "house", value: "Home") {
				HomeTab()
			}

			Tab("Resources", systemImage: "doc.text", value: "Resources") {
				ResourcesTab(selectedTab: $selectedTab)
			}

			Tab("Chat", systemImage: "bubble.left.and.bubble.right", value: "Chat") {
				ChatTab()
			}
            
            Tab("Noise", systemImage: "mic.full", value: "Noise") {
                SoundsTab()
            }

			Tab("Questions", systemImage: "questionmark.circle", value: "Questions") {
				QuestionsTab(showQuestionsSheet: $showQuestionsSheet)
			}
		}
		.sheet(isPresented: .constant(!hasCompletedIntro)) {
			IntroSheet(hasCompletedIntro: $hasCompletedIntro)
		}
		.sheet(isPresented: $showQuestionsSheet, onDismiss: {
			// When questions sheet is dismissed, switch back to Home tab
			selectedTab = "Home"
		}) {
			NavigationStack {
				ZStack {
					ColorfulView(color: .constant(.jelly))
						.opacity(0.3)
						.ignoresSafeArea()
					
					QuestionsOnlyView(onClose: {
						showQuestionsSheet = false
					})
				}
			}
			.frame(
				minWidth: 320, idealWidth: 500, maxWidth: 600,
				minHeight: 680, idealHeight: 700, maxHeight: 800
			)
			#if os(iOS)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						showQuestionsSheet = false
					} label: {
						Label("Close", systemImage: "xmark")
					}
				}
			}
			#endif
		}
	}
}

#Preview { ContentView() }
