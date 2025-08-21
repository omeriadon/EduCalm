//
//  EducalmApp.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import SwiftUI

@main
struct EduCalmApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.tint(.purple)
			#if os(macOS)
				.frame(width: 900, height: 700)
			#endif
		}
		.windowResizability(.contentSize)
	}
}
