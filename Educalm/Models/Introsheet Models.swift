//
//  Introsheet Models.swift
//  Educalm
//
//  Created by Adon Omeri on 20/8/2025.
//

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
