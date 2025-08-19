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

	static let userName = Key<String>("userName", default: "")
	static let userGender = Key<String>("userGender", default: "")
	static let userAge = Key<Int>("userAge", default: 0) // 0 if not specified
	static let userIsDisabled = Key<Bool>("userIsDisabled", default: false)

	static let userMentalHealthConcerns = Key<String>("userMentalHealthConcerns", default: "")
	static let userSeeingProfessional = Key<Bool>("userSeeingProfessional", default: false)
	static let userAverageMoodRating = Key<Int>("userAverageMoodRating", default: 5) // 1-10 scale
	static let userDistressingThoughtsFrequency = Key<Int>("userDistressingThoughtsFrequency", default: 0) // 0-10 scale
	static let userHasFriends = Key<Bool>("userHasFriends", default: false)
	static let userAvoidTopics = Key<String>("userAvoidTopics", default: "")
	static let userMotivationForMentalHealth = Key<String>("userMotivationForMentalHealth", default: "")
	static let userTrackMentalStability = Key<Bool>("userTrackMentalStability", default: false)
	static let userExamPreparation = Key<Bool>("userExamPreparation", default: false)
}
