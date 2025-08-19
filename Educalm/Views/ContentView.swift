//
//  ContentView.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import SwiftUI

struct ContentView: View {
	@State private var currentTab: AppTab = .home

	var body: some View {
		TabView(selection: $currentTab) {
			ForEach(AppTab.allCases) { tab in
				tab.view
					.tabItem {
						Label(tab.title, systemImage: tab.symbol)
					}
					.tag(tab)
			}
		}
	}
}

enum AppTab: String, CaseIterable, Identifiable {
	case home, resources, chat

	var id: Self { self }

	@ViewBuilder
	var view: some View {
		switch self {
		case .home:
			HomeTab()
		case .resources:
			ResourcesTab()
		case .chat:
			ChatTab()
		}
	}

	var title: String {
		switch self {
		case .home: "Home"
		case .resources: "Resources"
		case .chat: "Chat"
		}
	}

	var symbol: String {
		switch self {
		case .home: "house"
		case .resources: "doc.text"
		case .chat: "bubble.left.and.bubble.right"
		}
	}
}
