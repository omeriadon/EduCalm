//
//  Introsheet.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import ColorfulX
import Defaults
import SwiftUI

// MARK: - Hero Gradient

let heroGradient = LinearGradient(
	colors: [.purple, .blue],
	startPoint: .topLeading,
	endPoint: .bottomTrailing
)

// MARK: - Question Input Type

enum QuestionInputType {
	case text
	case gender
	case schoolGrade
}

// MARK: - Onboarding Question Model

struct OnboardingQuestion {
	let id: String
	let title: String
	let symbol: String
	let description: String
	let inputType: QuestionInputType
}

// MARK: - Onboarding Question View

struct OnboardingQuestionView: View {
	let question: OnboardingQuestion

	@Default(.userName) var userName
	@Default(.userGender) var userGender
	@Default(.userAge) var userAge
	@Default(.userSchoolGrade) var userSchoolGrade
	@Default(.userHasDisabilites) var userHasDisabilites
	@Default(.userMentalHealthConcerns) var userMentalHealthConcerns
	@Default(.userSeeingProfessional) var userSeeingProfessional
	@Default(.userAverageMoodRating) var userAverageMoodRating
	@Default(.userDistressingThoughtsFrequency) var userDistressingThoughtsFrequency
	@Default(.userHasFriends) var userHasFriends
	@Default(.userMotivationForMentalHealth) var userMotivationForMentalHealth
	@Default(.userTrackMentalStability) var userTrackMentalStability

	@State private var ageNumber: Int = 16

	var body: some View {
		VStack(spacing: 24) {
			VStack(spacing: 16) {
				Image(systemName: question.symbol)
					.font(.system(size: 60))
					.foregroundStyle(.blue)

				Text(question.title)
					.font(.title)
					.fontWeight(.bold)
					.multilineTextAlignment(.center)

				Text(question.description)
					.font(.body)
					.foregroundColor(.secondary)
					.multilineTextAlignment(.center)
			}

			Spacer()

			switch question.inputType {
			case .text:
				if question.id == "age" {
					ageStepper
				} else {
					textInput
				}

			case .gender:
				genderPicker

			case .schoolGrade:
				schoolGradePicker
			}

			Spacer()
		}
		.padding()
		.onAppear {
			if let age = Int(userAge), age > 0 {
				ageNumber = age
			}
		}
	}

	@ViewBuilder
	private var textInput: some View {
		TextField("Your response...", text: textBinding, axis: .vertical)
			.padding(8)
			.glassEffect(.clear, in: .rect(cornerRadius: 12))
			.textFieldStyle(.plain)
			.lineLimit(3 ... 6)
			.onSubmit {
				hideKeyboard()
			}
	}

	@ViewBuilder
	private var ageStepper: some View {
		VStack(spacing: 12) {
			Text("\(ageNumber)")
				.font(.largeTitle)
				.fontWeight(.bold)
				.animation(.easeInOut, value: ageNumber)
				.contentTransition(.numericText())

			Stepper("Age", value: $ageNumber, in: 12 ... 25)
				.onChange(of: ageNumber) { _, newValue in
					withAnimation {
						userAge = String(newValue)
					}
				}
				.labelsHidden()
				.controlSize(.extraLarge)
		}
		.frame(width: 100)
		.padding()
		.contentShape(Rectangle())
		.glassEffect(.clear, in: .rect(cornerRadius: 12))
	}

	@ViewBuilder
	private var genderPicker: some View {
		VStack(spacing: 12) {
			ForEach(Gender.allCases, id: \.self) { gender in
				Button {
					userGender = gender
				} label: {
					HStack {
						Text(gender.title)
						Spacer()
						Image(systemName: userGender == gender ? "checkmark.circle.fill" : "circle")
							.foregroundStyle(userGender == gender ? .blue : .secondary)
							.contentTransition(.symbolEffect(.replace))
					}
					.padding()
					.frame(maxWidth: .infinity)
					.contentShape(Rectangle())
					.glassEffect(.clear, in: .rect(cornerRadius: 12))
				}
				.buttonStyle(.plain)
				.animation(.easeOut(duration: 0.2), value: userGender == gender)
			}
		}
	}

	@ViewBuilder
	private var schoolGradePicker: some View {
		VStack(spacing: 12) {
			ForEach(SchoolGrade.allCases, id: \.self) { grade in
				Button {
					withAnimation(.easeInOut(duration: 0.2)) {
						userSchoolGrade = grade
					}
				} label: {
					HStack {
						Text(grade.title)
							.contentTransition(.numericText())
						Spacer()
						Image(systemName: userSchoolGrade == grade ? "checkmark.circle.fill" : "circle")
							.foregroundStyle(userSchoolGrade == grade ? .blue : .secondary)
							.contentTransition(.symbolEffect(.replace))
					}
					.padding()
					.frame(maxWidth: .infinity)
					.contentShape(Rectangle())
					.glassEffect(.clear, in: .rect(cornerRadius: 12))
				}
				.buttonStyle(.plain)
			}
		}
	}

	private var textBinding: Binding<String> {
		switch question.id {
		case "name": return $userName
		case "age": return $userAge
		case "disabilities": return $userHasDisabilites
		case "mentalHealth": return $userMentalHealthConcerns
		case "professional": return $userSeeingProfessional
		case "mood": return $userAverageMoodRating
		case "thoughts": return $userDistressingThoughtsFrequency
		case "friends": return $userHasFriends
		case "motivation": return $userMotivationForMentalHealth
		case "tracking": return $userTrackMentalStability
		default: return .constant("")
		}
	}

	private func hideKeyboard() {
		#if os(iOS)
			UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		#endif
	}
}

// MARK: - Onboarding Questions

let onboardingQuestions: [OnboardingQuestion] = [
	OnboardingQuestion(
		id: "name",
		title: "What's your name?",
		symbol: "person.fill",
		description: "Tell us what you'd like to be called",
		inputType: .text
	),
	OnboardingQuestion(
		id: "gender",
		title: "How do you identify?",
		symbol: "person.2.fill",
		description: "This helps us personalize your experience",
		inputType: .gender
	),
	OnboardingQuestion(
		id: "age",
		title: "How old are you?",
		symbol: "calendar",
		description: "Just your age in years",
		inputType: .text
	),
	OnboardingQuestion(
		id: "grade",
		title: "What year are you in?",
		symbol: "graduationcap.fill",
		description: "Select your current school year",
		inputType: .schoolGrade
	),
	OnboardingQuestion(
		id: "disabilities",
		title: "Do you have any learning differences or disabilities?",
		symbol: "accessibility",
		description: "This helps us provide better support (optional)",
		inputType: .text
	),
	OnboardingQuestion(
		id: "mentalHealth",
		title: "What brings you here today?",
		symbol: "heart.fill",
		description: "Tell us about any concerns, feelings, or challenges you're facing",
		inputType: .text
	),
	OnboardingQuestion(
		id: "professional",
		title: "Are you currently seeing a mental health professional?",
		symbol: "stethoscope",
		description: "This could be a psychologist, counselor, therapist, or psychiatrist",
		inputType: .text
	),
	OnboardingQuestion(
		id: "mood",
		title: "How would you rate your average mood lately?",
		symbol: "face.smiling",
		description: "Describe how you've been feeling overall",
		inputType: .text
	),
	OnboardingQuestion(
		id: "thoughts",
		title: "How often do you have distressing thoughts?",
		symbol: "brain.head.profile",
		description: "Tell us about any worrying or upsetting thoughts",
		inputType: .text
	),
	OnboardingQuestion(
		id: "friends",
		title: "Tell us about your social connections",
		symbol: "person.3.fill",
		description: "Do you have friends? How do you feel about your relationships?",
		inputType: .text
	),
	OnboardingQuestion(
		id: "motivation",
		title: "What motivates you to focus on your mental health?",
		symbol: "target",
		description: "What are you hoping to achieve or change?",
		inputType: .text
	),
	OnboardingQuestion(
		id: "tracking",
		title: "Are you interested in tracking your mental wellness?",
		symbol: "chart.line.uptrend.xyaxis",
		description: "Would you like to monitor your mood and progress over time?",
		inputType: .text
	),
]

// MARK: - Intro Sheet View

struct IntroSheet: View {
	@Binding var hasCompletedIntro: Bool

	@State var showQuestions: Bool = false
	@State var currentQuestionIndex = 0

	@State var colourfulPreset = ColorfulPreset.jelly

	var body: some View {
		GeometryReader { proxy in
			ZStack {
				ColorfulView(color: $colourfulPreset)
					.animation(.easeInOut(duration: 8), value: showQuestions)
					.opacity(showQuestions ? 0.3 : 0.5)
					.ignoresSafeArea()
				NavigationStack {
					if !showQuestions {
						VStack {
							Group {
								Text("Welcome to ")
									.fontWeight(.light)
									+
									Text("EduCalm")
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
						#if os(macOS)
							VStack {
								HStack {
									Button {
										hideKeyboard()
										withAnimation(.easeInOut(duration: 0.3)) {
											if currentQuestionIndex > 0 {
												currentQuestionIndex -= 1
											} else {
												showQuestions = false
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
												hasCompletedIntro = true
											}
										}
									} label: {
										Group {
											if currentQuestionIndex < onboardingQuestions.count - 1 {
												Label("Next", systemImage: "arrow.right")
											} else {
												Label("Done", systemImage: "checkmark.circle")
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
									.onChange(of: currentQuestionIndex) { index in
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
												showQuestions = false
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
												hasCompletedIntro = true
											}
										}
									} label: {
										if currentQuestionIndex < onboardingQuestions.count - 1 {
											Label("Next", systemImage: "arrow.right")
										} else {
											Label("Done", systemImage: "checkmark.circle")
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
			}
		}

		.interactiveDismissDisabled(true)
		.frame(
			minWidth: 320, idealWidth: 500, maxWidth: 600,
			minHeight: 680, idealHeight: 700, maxHeight: 800
		)
	}

	private func hideKeyboard() {
		#if os(iOS)
			UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		#endif
	}
}

#Preview {
	IntroSheet(hasCompletedIntro: .constant(false))
		.tint(.purple)
}
