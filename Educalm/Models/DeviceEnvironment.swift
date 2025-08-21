//
//  DeviceEnvironment.swift
//  Educalm
//
//  Created by Adon Omeri on 19/8/2025.
//

import Foundation

#if canImport(UIKit)
	import UIKit
#endif

enum DeviceEnvironment {
	static var isiPadPhone: Bool {
		#if os(iOS)
			return true
		#else
			return false // Not iPad on macOS, visionOS, tvOS, etc.
		#endif
	}

	static var isMac: Bool {
		#if os(macOS)
			return true
		#else
			return false
		#endif
	}

	static var isVision: Bool {
		#if os(visionOS)
			return true
		#else
			return false
		#endif
	}

	static var isDesktop: Bool {
		#if os(macOS) || os(visionOS)
			return true
		#else
			return false
		#endif
	}
}
