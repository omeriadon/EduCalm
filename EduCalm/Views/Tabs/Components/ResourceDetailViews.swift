//
//  ResourceDetailViews.swift
//  EduCalm
//
//  Created by Adon Omeri on 20/8/2025.
//

import ColorfulX
import SwiftUI

struct PeopleDetailView: View {
	let people: [PersonResource]
	@State var colourfulPreset = ColorfulPreset.aurora

	var body: some View {
		ZStack {
			ColorfulView(color: $colourfulPreset)
				.opacity(0.3)
				.ignoresSafeArea()

			ScrollView {
				ForEach(people) { person in
					VStack {
						Label(person.title, systemImage: person.symbol)
							.font(.title2)
							.bold()
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.bottom, 4)

						if let description = person.description {
							Text(description)
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding(.bottom, 8)
						}
					}
					.foregroundStyle(.white)
					.padding()
					.glassEffect(
						.regular.tint(.random.opacity(0.4)).interactive(),
						in: .rect(cornerRadius: 17)
					)
					.padding(.horizontal)
				}
				.padding(.bottom)
			}
			.navigationTitle("People")
			.scrollContentBackground(.hidden)
			.scrollEdgeEffectStyle(.soft, for: .top)
		}
	}
}

struct HelplinesDetailView: View {
	let helplines: [HelplineResource]
	@State var colourfulPreset = ColorfulPreset.ocean

	var body: some View {
		ZStack {
			ColorfulView(color: $colourfulPreset)
				.opacity(0.25)
				.ignoresSafeArea()

			ScrollView {
				ForEach(helplines) { helpline in
					Button {
						if let phoneURL = helpline.phoneURL {
							#if os(iOS)
								UIApplication.shared.open(phoneURL)
							#elseif os(macOS)
								NSWorkspace.shared.open(phoneURL)
							#endif
						}
					} label: {
						HStack {
							VStack {
								Label(helpline.title, systemImage: "phone.fill")
									.font(.title2)
									.bold()
									.frame(maxWidth: .infinity, alignment: .leading)

								if let description = helpline.description {
									Text(description)
										.frame(maxWidth: .infinity, alignment: .leading)
								}
							}

							Label("Call", systemImage: "phone.fill")
								.padding(8)
								.font(DeviceEnvironment.isiPadPhone ? .caption : .headline)
								.foregroundColor(.green)
								.glassEffect(
									.regular,
									in: .rect(cornerRadius: 8)
								)
						}
						.foregroundStyle(.white)
						.padding()
						.glassEffect(
							.regular.tint(.random.opacity(0.4)).interactive(),
							in: .rect(cornerRadius: 17)
						)
					}
					.buttonStyle(.plain)
					.padding(.horizontal)
				}
				.padding(.bottom)
			}
			.navigationTitle("Helplines")
			.scrollContentBackground(.hidden)
			.scrollEdgeEffectStyle(.soft, for: .top)
		}
	}
}

struct WebsitesDetailView: View {
	let websites: [WebsiteResource]
	@State var colourfulPreset = ColorfulPreset.winter

	var body: some View {
		ZStack {
			ColorfulView(color: $colourfulPreset)
				.opacity(0.25)
				.ignoresSafeArea()

			ScrollView {
				ForEach(websites) { website in
					Button {
						if let webURL = website.webURL {
							#if os(iOS)
								UIApplication.shared.open(webURL)
							#elseif os(macOS)
								NSWorkspace.shared.open(webURL)
							#endif
						}
					} label: {
						HStack {
							VStack {
								Label(website.title, systemImage: "globe")
									.font(.title2)
									.bold()
									.frame(maxWidth: .infinity, alignment: .leading)

								if let description = website.description {
									Text(description)
										.frame(maxWidth: .infinity, alignment: .leading)
								}
							}

							Label("Open", systemImage: "link")
								.padding(8)
								.font(DeviceEnvironment.isiPadPhone ? .caption : .headline)
								.foregroundColor(.blue)
								.glassEffect(
									.regular,
									in: .rect(cornerRadius: 8)
								)
						}
						.foregroundStyle(.white)
						.padding()
						.glassEffect(
							.regular.tint(.random.opacity(0.4)).interactive(),
							in: .rect(cornerRadius: 17)
						)
					}
					.buttonStyle(.plain)
					.padding(.horizontal)
				}
				.padding(.bottom)
			}
			.navigationTitle("Websites")
			.scrollContentBackground(.hidden)
			.scrollEdgeEffectStyle(.soft, for: .top)
		}
	}
}

struct AppsDetailView: View {
	let apps: [AppResource]
	@State var colourfulPreset = ColorfulPreset.lavandula

	var body: some View {
		ZStack {
			ColorfulView(color: $colourfulPreset)
				.opacity(0.3)
				.ignoresSafeArea()

			ScrollView {
				ForEach(apps) { app in
					Button {
						if let storeURL = app.storeURL {
							#if os(iOS)
								UIApplication.shared.open(storeURL)
							#elseif os(macOS)
								NSWorkspace.shared.open(storeURL)
							#endif
						}
					} label: {
						HStack {
							VStack {
								Label(app.title, systemImage: "app.badge")
									.font(.title2)
									.bold()
									.frame(maxWidth: .infinity, alignment: .leading)

								if let description = app.description {
									Text(description)
										.frame(maxWidth: .infinity, alignment: .leading)
								}
							}

							Label("Download", systemImage: "arrow.down.circle.fill")
								.padding(8)
								.font(DeviceEnvironment.isiPadPhone ? .caption : .headline)
								.foregroundColor(.purple)
								.glassEffect(
									.regular,
									in: .rect(cornerRadius: 8)
								)
						}

						.foregroundStyle(.white)
						.padding()
						.glassEffect(
							.regular.tint(.random.opacity(0.4)).interactive(),
							in: .rect(cornerRadius: 17)
						)
					}
					.buttonStyle(.plain)
					.padding(.horizontal)
				}
				.padding(.bottom)
			}
			.navigationTitle("Apps")
			.scrollContentBackground(.hidden)
			.scrollEdgeEffectStyle(.soft, for: .top)
		}
	}
}
