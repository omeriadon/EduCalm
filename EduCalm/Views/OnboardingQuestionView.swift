//
//  OnboardingQuestionView.swift
//  EduCalm
//
//  Created by Adon Omeri on 24/8/2025.
//

import SwiftUI
import Defaults

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
