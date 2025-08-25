	//
	//  Resources Models.swift
	//  Educalm
	//
	//  Created by Adon Omeri on 20/8/2025.
	//

import Foundation

enum ResourceType: CaseIterable {
	case people, helplines, websites, apps, chat
}

struct PersonResource: Identifiable, Hashable {
	let id = UUID()
	let symbol: String
	let title: String
	let description: String?
}

struct HelplineResource: Identifiable, Hashable {
	let id = UUID()
	let title: String
	let phoneNumber: String
	let description: String?

	var phoneURL: URL? {
		URL(string: "tel:\(phoneNumber)")
	}
}

struct WebsiteResource: Identifiable, Hashable {
	let id = UUID()
	let title: String
	let url: String
	let description: String?

	var webURL: URL? {
		URL(string: url)
	}
}

struct AppResource: Identifiable, Hashable {
	let id = UUID()
	let title: String
	let appStoreURL: String
	let description: String?

	var storeURL: URL? {
		URL(string: appStoreURL)
	}
}

struct ResourceSection: Identifiable, CaseIterable, Hashable {
	let id = UUID()
	let title: String
	let description: String
	let symbol: String
	let resourceType: ResourceType
	let people: [PersonResource]?
	let helplines: [HelplineResource]?
	let websites: [WebsiteResource]?
	let apps: [AppResource]?
	let chatAction: (() -> Void)?

	init(title: String, description: String, symbol: String, resourceType: ResourceType, people: [PersonResource]? = nil, helplines: [HelplineResource]? = nil, websites: [WebsiteResource]? = nil, apps: [AppResource]? = nil, chatAction: (() -> Void)? = nil) {
		self.title = title
		self.description = description
		self.symbol = symbol
		self.resourceType = resourceType
		self.people = people
		self.helplines = helplines
		self.websites = websites
		self.apps = apps
		self.chatAction = chatAction
	}

	static var allCases: [ResourceSection] {
		[
			ResourceSection(title: "People", description: "Connect with professionals", symbol: "person.2.fill", resourceType: .people, people: []),
			ResourceSection(title: "Helplines", description: "Crisis support and guidance", symbol: "phone.fill", resourceType: .helplines, helplines: []),
			ResourceSection(title: "Websites", description: "Online resources and information", symbol: "globe", resourceType: .websites, websites: []),
			ResourceSection(title: "Apps", description: "Mental health applications", symbol: "app.badge", resourceType: .apps, apps: []),
			ResourceSection(title: "Chat", description: "Talk to our AI assistant", symbol: "message.fill", resourceType: .chat, chatAction: {})
		]
	}

	static func == (lhs: ResourceSection, rhs: ResourceSection) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}


