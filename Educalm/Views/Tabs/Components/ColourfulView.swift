//
//  ColourfulView.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import ColorfulX
import SwiftUI

struct ColourfulView: View {
	var body: some View {

	}
}

enum ColourOptions: String, CaseIterable, Identifiable {
	case home, resources, chat

	var id: String { self.rawValue }

	var colour: ColorfulPreset {
		switch self {
			case .home:
				ColorfulPreset.jelly
			case .resources:
				ColorfulPreset.autumn
			case .chat:
				ColorfulPreset.sunrise
		}
	}
}

#Preview {
	ColourfulView()
}
