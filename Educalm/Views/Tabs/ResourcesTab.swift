//
//  ResourcesTab.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import ColorfulX
import SwiftUI

struct ResourcesTab: View {
	@State var colourfulPreset = ColorfulPreset.dandelion

	let resourceSections = [
		ResourceSection(title: "People", description: "Connect with professionals", symbol: "person.2.fill", resourceType: .people,
		                people: [
		                	PersonResource(symbol: "stethoscope", title: "General Practitioner", description: "Primary healthcare provider for medical consultations"),
		                	PersonResource(symbol: "brain.head.profile", title: "Psychologist", description: "Mental health professional specializing in therapy"),
		                	PersonResource(symbol: "cross", title: "Counselor", description: "Trained professional providing guidance and support"),
		                	PersonResource(symbol: "heart.text.square", title: "Therapist", description: "Licensed practitioner for mental health treatment"),
		                ]),
		ResourceSection(title: "Helplines", description: "Crisis support and guidance", symbol: "phone.fill", resourceType: .helplines,
		                helplines: [
		                	HelplineResource(title: "Lifeline", phoneNumber: "131114", description: "24/7 crisis support"),
		                	HelplineResource(title: "Beyond Blue", phoneNumber: "1300224636", description: "Depression and anxiety support"),
		                	HelplineResource(title: "Kids Helpline", phoneNumber: "1800551800", description: "Support for young people"),
		                ]),
		ResourceSection(title: "Websites", description: "Online resources and information", symbol: "globe", resourceType: .websites,
		                websites: [
		                	WebsiteResource(title: "Beyond Blue", url: "https://beyondblue.org.au", description: "Mental health information"),
		                	WebsiteResource(title: "Headspace", url: "https://headspace.org.au", description: "Youth mental health"),
		                	WebsiteResource(title: "ReachOut", url: "https://reachout.com", description: "Mental health resources for young people"),
		                ]),
		ResourceSection(title: "Apps", description: "Mental health applications", symbol: "app.badge", resourceType: .apps,
		                apps: [
		                	AppResource(title: "Headspace", appStoreURL: "https://apps.apple.com/app/headspace/id493145008", description: "Meditation and mindfulness"),
		                	AppResource(title: "Calm", appStoreURL: "https://apps.apple.com/app/calm/id571800810", description: "Sleep and relaxation"),
		                	AppResource(title: "MindShift", appStoreURL: "https://apps.apple.com/app/mindshift/id634684825", description: "Anxiety management"),
		                ]),
		ResourceSection(title: "Chat", description: "Talk to our AI assistant", symbol: "message.fill", resourceType: .chat,
		                chatAction: {
		                	// This closure will be called when chat is selected
		                }),
	]

	var body: some View {
		NavigationStack {
			ZStack {
				ColorfulView(color: $colourfulPreset)
					.opacity(0.5)
					.ignoresSafeArea()

				ScrollView {
					ForEach(resourceSections) { section in
						ResourceSectionView(section: section)
					}
				}
				.background(Color.clear)
				.scrollContentBackground(.hidden)
				.scrollEdgeEffectStyle(.soft, for: .top)
				.navigationTitle("Resources")
			}
		}
	}
}

struct ResourceSectionView: View {
	let section: ResourceSection
	@State private var isNavigating = false

	var body: some View {
		Button {
			isNavigating = true
		} label: {
			VStack {
				Label(section.title, systemImage: section.symbol)
					.font(.title)
					.bold()
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.bottom, 4)

				Text(section.description)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			.foregroundStyle(.white)
			.padding()
			.contentShape(RoundedRectangle(cornerRadius: 17))
			.frame(maxWidth: .infinity)
			.glassEffect(
				.regular.tint(.random.opacity(0.4)).interactive(),
				in: .rect(cornerRadius: 17)
			)
		}
		.buttonStyle(.plain)
		.padding(.horizontal)
		.navigationDestination(isPresented: $isNavigating) {
			destinationView
		}
	}

	@ViewBuilder
	private var destinationView: some View {
		switch section.resourceType {
		case .people:
			PeopleDetailView(people: section.people ?? [])
		case .helplines:
			HelplinesDetailView(helplines: section.helplines ?? [])
		case .websites:
			WebsitesDetailView(websites: section.websites ?? [])
		case .apps:
			AppsDetailView(apps: section.apps ?? [])
		case .chat:
			ChatDetailView()
		}
	}
}

#Preview {
	ResourcesTab()
}
