	//
	//  Introsheet.swift
	//  Educalm
	//
	//  Created by Adon Omeri on 19/8/2025.
	//

import ColorfulX
import Defaults
import SwiftUI

	// MARK: - Shared Questions Navigation Component

struct QuestionsNavigationView: View {
	@State var currentQuestionIndex = 0
	let onBack: (() -> Void)?
	let onComplete: () -> Void

	var body: some View {
		GeometryReader { proxy in
#if os(macOS)
			VStack {
				HStack {
					Button {
						hideKeyboard()
						withAnimation(.easeInOut(duration: 0.3)) {
							if currentQuestionIndex > 0 {
								currentQuestionIndex -= 1
							} else {
								onBack?()
							}
						}
					} label: {
						Label("Back", systemImage: "arrow.left")
					}
					.buttonStyle(.glass)
					.controlSize(.extraLarge)
					Spacer()
					Text("\(currentQuestionIndex + 1) of \(onboardingQuestions.count)")
						.animation(
							.easeInOut(duration: 2),
							value: currentQuestionIndex
						)
						.contentTransition(.numericText())
						.font(.caption)
						.foregroundColor(.secondary)
					Spacer()
					Button {
						hideKeyboard()
						withAnimation(.easeInOut(duration: 0.3)) {
							if currentQuestionIndex < onboardingQuestions.count - 1 {
								currentQuestionIndex += 1
							} else {
								onComplete()
							}
						}
					} label: {
						Group {
							if currentQuestionIndex < onboardingQuestions.count - 1 {
								Label("Next", systemImage: "arrow.right")
							} else {
								Label("Save", systemImage: "checkmark")
							}
						}
						.animation(.easeInOut, value: currentQuestionIndex)
						.contentTransition(.numericText())
					}
					.controlSize(.extraLarge)
					.buttonStyle(.glassProminent)
				}
				.padding()
				ScrollViewReader { scrollProxy in
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(spacing: 0) {
							ForEach(0 ..< onboardingQuestions.count, id: \.self) { index in
								OnboardingQuestionView(question: onboardingQuestions[index])
									.frame(
										width: proxy.size.width
									)
									.id(index)
							}
						}
					}
					.onChange(of: currentQuestionIndex) { _, index in
						withAnimation(.easeInOut(duration: 0.3)) {
							scrollProxy.scrollTo(index, anchor: .leading)
						}
					}
				}
				.ignoresSafeArea(.all, edges: .top)
				.scrollTargetBehavior(.paging)
				.scrollPosition(id: .constant(currentQuestionIndex))
				.scrollDisabled(true)
			}
#else
			TabView(selection: $currentQuestionIndex) {
				ForEach(0 ..< onboardingQuestions.count, id: \.self) { index in
					ScrollView(.vertical) {
						OnboardingQuestionView(question: onboardingQuestions[index])
							.frame(width: proxy.size.width)
					}
					.tag(index)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .automatic))
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						hideKeyboard()
						withAnimation(.easeInOut(duration: 0.3)) {
							if currentQuestionIndex > 0 {
								currentQuestionIndex -= 1
							} else {
								onBack?()
							}
						}
					} label: {
						Label("Back", systemImage: "arrow.left")
					}
					.controlSize(.extraLarge)
				}

				ToolbarItem(placement: .principal) {
					Text("\(currentQuestionIndex + 1) of \(onboardingQuestions.count)")
						.contentTransition(.numericText())
						.font(.caption)
						.foregroundColor(.secondary)
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button {
						hideKeyboard()
						withAnimation(.easeInOut(duration: 0.3)) {
							if currentQuestionIndex < onboardingQuestions.count - 1 {
								currentQuestionIndex += 1
							} else {
								onComplete()
							}
						}
					} label: {
						if currentQuestionIndex < onboardingQuestions.count - 1 {
							Label("Next", systemImage: "arrow.right")
						} else {
							Label("Save", systemImage: "checkmark")
						}
					}
					.controlSize(.extraLarge)
					.buttonStyle(.glassProminent)
				}
			}
			.onTapGesture {
				hideKeyboard()
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.animation(.easeInOut(duration: 0.3), value: currentQuestionIndex)
#endif
		}
	}

	private func hideKeyboard() {
#if os(iOS)
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
	}
}

// MARK: - Questions Only View

struct QuestionsOnlyView: View {
	let onClose: (() -> Void)?

	var body: some View {
		QuestionsNavigationView(
			onBack: onClose,
			onComplete: { onClose?() }
		)
	}
}

// MARK: - Intro Sheet View

struct IntroSheet: View {
	@Binding var hasCompletedIntro: Bool
	let onClose: (() -> Void)?

	@State var showQuestions: Bool = false

	@State var colourfulPreset = ColorfulPreset.jelly

	init(hasCompletedIntro: Binding<Bool> = .constant(false), onClose: (() -> Void)? = nil) {
		_hasCompletedIntro = hasCompletedIntro
		self.onClose = onClose
	}

	var body: some View {
		GeometryReader { proxy in
			ZStack {
				ColorfulView(color: $colourfulPreset)
					.animation(.easeInOut(duration: 8), value: showQuestions)
					.opacity(showQuestions ? 0.3 : 0.5)
					.ignoresSafeArea()
				NavigationStack {
					if !showQuestions {
						WelcomeSplashScreen {
							showQuestions = true
						}
					} else {
						QuestionsNavigationView(
							onBack: {
								withAnimation(.easeInOut(duration: 0.3)) {
									showQuestions = false
								}
							},
							onComplete: {
								hasCompletedIntro = true
								onClose?()
							}
						)
					}
				}
			}
		}
		.interactiveDismissDisabled(onClose == nil) // Allow dismiss when close action is provided
		.frame(
			minWidth: 320, idealWidth: 500, maxWidth: 600,
			minHeight: 680, idealHeight: 700, maxHeight: 800
		)
#if os(iOS)
		.toolbar {
			if let onClose = onClose {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						onClose()
					} label: {
						Label("Close", systemImage: "xmark")
					}
				}
			}
		}
#endif
	}
}

//#Preview("Onboarding") {
//	IntroSheet(hasCompletedIntro: .constant(false))
//		.tint(.purple)
//}
//
//#Preview("Questions") {
//	IntroSheet(hasCompletedIntro: .constant(false), onClose: {
//		print("Close tapped")
//	})
//	.tint(.purple)
//}

