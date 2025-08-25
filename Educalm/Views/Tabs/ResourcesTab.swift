//
//  ResourcesTab.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import ColorfulX
import SwiftUI

struct ResourcesTab: View {
	@Binding var selectedTab: String
	@State var colourfulPreset = ColorfulPreset.dandelion

	private var resourceSections: [ResourceSection] {
		[
			ResourceSection(title: "People", description: "Connect with professionals", symbol: "person.2.fill", resourceType: .people,
			                people: [
			                	PersonResource(symbol: "brain.head.profile", title: "School Psychologist", description: "Mental health professional specializing in therapy"),
			                	PersonResource(symbol: "graduationcap", title: "Teacher", description: """
			                	Daily support and guidance at school
			                	Extend due dates
			                	"""),
			                	PersonResource(symbol: "heart.text.square", title: "Therapist", description: "Licensed practitioner for mental health treatment"),
			                	PersonResource(symbol: "person.3", title: "Parents", description: "Family support and understanding"),
			                	PersonResource(symbol: "person.line.dotted.person", title: "Friends", description: "Trusted support network"),
			                	PersonResource(symbol: "stethoscope", title: "Doctor", description: "Medical conditions and serious cases"),
			                	PersonResource(symbol: "person.crop.circle.badge.questionmark", title: "School Counselor", description: "Academic, emotional, and social guidance"),
			                	PersonResource(symbol: "globe", title: "Community Leader", description: "Local resources and advocacy"),
			                	PersonResource(symbol: "staroflife", title: "Emergency Services", description: "Immediate response for critical situations"),
			                ]),
			ResourceSection(title: "Helplines", description: "Crisis support and guidance", symbol: "phone.fill", resourceType: .helplines,
			                helplines: [
			                	HelplineResource(title: "Lifeline", phoneNumber: "131114", description: "24/7 crisis support"),
			                	HelplineResource(title: "Beyond Blue", phoneNumber: "1300224636", description: "24/7 support for anxiety and depression"),
			                	HelplineResource(title: "Kids Helpline", phoneNumber: "1800551800", description: "24/7 free confidential counselling for ages 5–25"),
			                	HelplineResource(title: "CAMHS Crisis Connect", phoneNumber: "1800048636", description: "WA 24/7 mental health crisis line for young people"),
			                	HelplineResource(title: "Suicide Call Back Service", phoneNumber: "1300659467", description: "24/7 counselling for suicidal thoughts, grief, distress"),
			                	HelplineResource(title: "13YARN", phoneNumber: "139276", description: "24/7 culturally safe crisis support for Aboriginal and Torres Strait Islander peoples"),
			                	HelplineResource(title: "QLife", phoneNumber: "1800184527", description: "LGBTQIA+ peer support (phone and webchat daily)"),
			                	HelplineResource(title: "1800RESPECT", phoneNumber: "1800737732", description: "24/7 sexual assault and family/domestic violence counselling"),
			                	HelplineResource(title: "Butterfly Foundation", phoneNumber: "1800334673", description: "Eating disorder and body image helpline, webchat, email"),
			                	HelplineResource(title: "Headspace", phoneNumber: "1800650890", description: "Youth mental health support and service navigation"),
			                	HelplineResource(title: "MensLine Australia", phoneNumber: "1300789978", description: "24/7 counselling for men’s mental health and relationships"),
			                	HelplineResource(title: "Poisons Information Centre", phoneNumber: "131126", description: "24/7 advice for poisoning, overdose, medication errors"),
			                ]),
			ResourceSection(title: "Websites", description: "Online resources and information", symbol: "globe", resourceType: .websites,
			                websites: [
			                	WebsiteResource(title: "Beyond Blue", url: "https://www.beyondblue.org.au", description: "Mental health information"),
			                	WebsiteResource(title: "Headspace", url: "https://headspace.org.au", description: "Youth mental health"),
			                	WebsiteResource(title: "ReachOut", url: "https://au.reachout.com", description: "Articles, tools, peer forum for young people"),
			                	WebsiteResource(title: "Butterfly Foundation", url: "https://butterfly.org.au", description: "Eating disorder and body image support, resources, helpline"),
			                	WebsiteResource(title: "Youth Focus", url: "https://youthfocus.com.au", description: "WA-based free mental health services for ages 12–25"),
			                	// Added
			                	WebsiteResource(title: "Kids Helpline", url: "https://kidshelpline.com.au", description: "24/7 phone, webchat, and email counselling for ages 5–25"),
			                	WebsiteResource(title: "Lifeline", url: "https://www.lifeline.org.au", description: "24/7 crisis support and suicide prevention (phone, text, chat)"),
			                	WebsiteResource(title: "Suicide Call Back Service", url: "https://www.suicidecallbackservice.org.au", description: "24/7 phone and online counselling for suicidal thoughts, grief, distress"),
			                	WebsiteResource(title: "Black Dog Institute", url: "https://www.blackdoginstitute.org.au", description: "Evidence-based mental health tools, factsheets, programs"),
			                	WebsiteResource(title: "Orygen", url: "https://www.orygen.org.au", description: "Youth mental health research, clinical resources, early intervention focus"),
			                	WebsiteResource(title: "Head to Health", url: "https://www.headtohealth.gov.au", description: "Government portal directing to trusted digital mental health supports"),
			                	WebsiteResource(title: "QLife", url: "https://qlife.org.au", description: "Nationwide LGBTQ+ peer support via phone and webchat"),
			                	WebsiteResource(title: "Minus18", url: "https://www.minus18.org.au", description: "Support, education, safe spaces for LGBTQIA+ youth"),
			                	WebsiteResource(title: "Batyr", url: "https://www.batyr.com.au", description: "Programs reducing stigma and promoting help-seeking in young people"),
			                	WebsiteResource(title: "Beyond Now (Web)", url: "https://www.beyondblue.org.au/get-support/beyond-now-suicide-safety-planning", description: "Online suicide safety planning tool"),
			                	WebsiteResource(title: "eSafety Commissioner", url: "https://www.esafety.gov.au", description: "Guidance on managing online harm, abuse, and digital wellbeing"),
			                	WebsiteResource(title: "Project Rockit", url: "https://www.projectrockit.com.au", description: "Anti-bullying and digital wellbeing education for students"),
			                ]),
			ResourceSection(title: "Apps", description: "Mental health applications", symbol: "app.badge", resourceType: .apps,
			                apps: [
			                	AppResource(title: "Headspace", appStoreURL: "https://apps.apple.com/app/headspace/id493145008", description: "Meditation and mindfulness"),
			                	AppResource(title: "Calm", appStoreURL: "https://apps.apple.com/app/calm/id571800810", description: "Sleep and relaxation"),
			                	AppResource(title: "MindShift", appStoreURL: "https://apps.apple.com/app/mindshift/id634684825", description: "Anxiety management"),
			                	AppResource(title: "Smiling Mind", appStoreURL: "https://apps.apple.com/au/app/smiling-mind/id560442518", description: "A free meditation and mindfulness app for all ages, with programs specifically for young students to help with stress and wellbeing."),
			                	AppResource(title: "ClearlyMe", appStoreURL: "https://apps.apple.com/au/app/clearlyme/id1550213032", description: "A free mental health app from the Black Dog Institute using CBT to help teens with low mood and anxiety."),
			                	AppResource(title: "MOST", appStoreURL: "https://apps.apple.com/au/app/most-mental-health-support/id6446385696", description: "https://apps.apple.com/au/app/most-mental-health-support/id6446385696"),
			                	// Added
			                	AppResource(title: "Insight Timer", appStoreURL: "https://apps.apple.com/au/app/insight-timer-meditation-app/id337472899", description: "Large free library of guided meditations, timers, and sleep tracks."),
			                	AppResource(title: "MoodMission", appStoreURL: "https://apps.apple.com/au/app/moodmission/id1068860721", description: "Evidence-based strategies for anxiety and low mood delivered as small actionable missions."),
			                	AppResource(title: "Clear Fear", appStoreURL: "https://apps.apple.com/au/app/clear-fear/id1102618766", description: "Anxiety support using CBT tools: breathing, thought reframing, coping strategies."),
			                	AppResource(title: "Calm Harm", appStoreURL: "https://apps.apple.com/au/app/calm-harm/id961611799", description: "Structured tasks to help manage and delay self-harm urges; distraction and soothing modes."),
			                	AppResource(title: "ReachOut WorryTime", appStoreURL: "https://apps.apple.com/au/app/reachout-worrytime/id1087338909", description: "Schedules worrying into a set window to reduce repetitive intrusive thought loops."),
			                	AppResource(title: "Beyond Now", appStoreURL: "https://apps.apple.com/au/app/beyondnow/id1044977156", description: "Personal safety plan: warning signs, coping steps, reasons for living, support contacts."),
			                	AppResource(title: "ReachOut Breathe", appStoreURL: "https://apps.apple.com/au/app/reachout-breathe/id1049219937", description: "Guided paced breathing with visual feedback to lower physical stress response."),
			                	AppResource(title: "Ten Percent Happier", appStoreURL: "https://apps.apple.com/au/app/ten-percent-happier-meditation/id992210239", description: "Secular meditation courses and short practices targeting stress and focus."),
			                	AppResource(title: "Sleep Cycle", appStoreURL: "https://apps.apple.com/au/app/sleep-cycle-sleep-tracker/id320606217", description: "Sleep tracking and smart alarm to improve sleep quality as a mood foundation."),
			                	AppResource(title: "Daylio", appStoreURL: "https://apps.apple.com/au/app/daylio-journal/id1194023242", description: "Low-effort mood and activity tracker generating trend insights and patterns."),
			                ]),
			ResourceSection(title: "Chat", description: "Talk to our AI assistant", symbol: "message.fill", resourceType: .chat,
			                chatAction: {
			                	selectedTab = "Chat"
			                }),
		]
	}

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
			if section.resourceType == .chat {
				section.chatAction?()
			} else {
				isNavigating = true
			}
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
			EmptyView() // Chat now switches tabs instead of navigating
		}
	}
}

#Preview {
	ResourcesTab(selectedTab: .constant("Resources"))
}
