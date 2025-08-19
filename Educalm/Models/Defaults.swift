//
//  Defaults.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import Defaults
import Foundation

extension Defaults.Keys {
	static let hasCompletedIntro = Key<Bool>("hasCompletedIntro", default: false)

	// Basic user info - strings for natural input
	static let userName = Key<String>("userName", default: "")
	static let userGender = Key<Gender>("userGender", default: .other)
	static let userAge = Key<String>("userAge", default: "")
	static let userSchoolGrade = Key<SchoolGrade>(
		"userSchoolGrade",
		default: .seven
	)
	static let userHasDisabilites = Key<String>("userHasDisabilites", default: "")

	// Mental health context for AI
	static let userMentalHealthConcerns = Key<String>("userMentalHealthConcerns", default: "")
	static let userSeeingProfessional = Key<String>("userSeeingProfessional", default: "")
	static let userAverageMoodRating = Key<String>("userAverageMoodRating", default: "")
	static let userDistressingThoughtsFrequency = Key<String>("userDistressingThoughtsFrequency", default: "")
	static let userHasFriends = Key<String>("userHasFriends", default: "")
	static let userMotivationForMentalHealth = Key<String>("userMotivationForMentalHealth", default: "")
	static let userTrackMentalStability = Key<String>("userTrackMentalStability", default: "")

	// AI inference categories - populated by analyzing user responses
	static let inferredPrimaryCondition = Key<String>("inferredPrimaryCondition", default: "")
	static let inferredSecondaryConditions = Key<[String]>("inferredSecondaryConditions", default: [])
	static let inferredSeverityLevel = Key<String>("inferredSeverityLevel", default: "") // mild, moderate, severe
	static let inferredTriggers = Key<[String]>("inferredTriggers", default: [])
	static let inferredCopingStyle = Key<String>("inferredCopingStyle", default: "")
	static let inferredSupportNeeds = Key<[String]>("inferredSupportNeeds", default: [])
	static let inferredRiskFactors = Key<[String]>("inferredRiskFactors", default: [])
}

enum Gender: Codable, Defaults.Serializable, CaseIterable {
	case male, female, other

	var title: String {
		switch self {
		case .male:
			"Male"
		case .female:
			"Female"
		case .other:
			"Other"
		}
	}
}

enum SchoolGrade: Int, Codable, Defaults.Serializable, CaseIterable {
	case seven = 7, eight = 8, nine = 9, ten = 10, eleven = 11, twelve = 12

	var title: String {
		switch self {
		case .seven:
			"Year 7"
		case .eight:
			"Year 8"
		case .nine:
			"Year 9"
		case .ten:
			"Year 10"
		case .eleven:
			"Year 11"
		case .twelve:
			"Year 12"
		}
	}
}
