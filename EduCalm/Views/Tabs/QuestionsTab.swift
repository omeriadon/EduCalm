//
//  QuestionsTab.swift
//  EduCalm
//
//  Created by Adon Omeri on 24/8/2025.
//

import ColorfulX
import SwiftUI

struct QuestionsTab: View {
	@Binding var showQuestionsSheet: Bool

	@State var colourfulPreset = ColorfulPreset.autumn

	var body: some View {
		ZStack {
			ColorfulView(color: $colourfulPreset)
				.opacity(0.4)
				.ignoresSafeArea()

			NavigationStack {
				ScrollView {}
					.scrollContentBackground(.hidden)
					.background(Color.clear)
					.onAppear {
						showQuestionsSheet = true
					}
			}
		}
	}
}

#Preview {
	QuestionsTab(showQuestionsSheet: .constant(false))
}
