//
//  View+.swift
//  EduCalm
//
//  Created by Adon Omeri on 24/8/2025.
//

import SwiftUI

extension ScrollTargetBehavior where Self == CustomHorizontalPagingBehavior {
	/// Usage: `.scrollTargetBehavior(.horizontalPaging)`
	static var horizontalPaging: CustomHorizontalPagingBehavior { .init() }
}

/// Usage: `.scrollTargetBehavior(.horizontalPaging)`
struct CustomHorizontalPagingBehavior: ScrollTargetBehavior {
	enum Direction {
		case left, right, none
	}

	func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
		let scrollViewWidth = context.containerSize.width
		let contentWidth = context.contentSize.width

		// If the content width is less than or equal to the ScrollView width, align to the leftmost position
		guard contentWidth > scrollViewWidth else {
			target.rect.origin.x = 0
			return
		}

		let originalOffset = context.originalTarget.rect.minX
		let targetOffset = target.rect.minX

		// Determine the scroll direction by comparing the original offset with the target offset
		let direction: Direction = targetOffset > originalOffset ? .left : (targetOffset < originalOffset ? .right : .none)
		guard direction != .none else {
			target.rect.origin.x = originalOffset
			return
		}

		let thresholdRatio: CGFloat = 1 / 3

		// Calculate the remaining content width based on the scroll direction and determine the drag threshold
		let remaining: CGFloat = direction == .left
			? (contentWidth - context.originalTarget.rect.maxX)
			: (context.originalTarget.rect.minX)

		let threshold = remaining <= scrollViewWidth ? remaining * thresholdRatio : scrollViewWidth * thresholdRatio

		let dragDistance = originalOffset - targetOffset
		var destination: CGFloat = originalOffset

		if abs(dragDistance) > threshold {
			// If the drag distance exceeds the threshold, adjust the target to the previous or next page
			destination = dragDistance > 0 ? originalOffset - scrollViewWidth : originalOffset + scrollViewWidth
		} else {
			// If the drag distance is within the threshold, align based on the scroll direction
			if direction == .right {
				// Scroll right (page left), round up
				destination = ceil(originalOffset / scrollViewWidth) * scrollViewWidth
			} else {
				// Scroll left (page right), round down
				destination = floor(originalOffset / scrollViewWidth) * scrollViewWidth
			}
		}

		// Boundary handling: Ensure the destination is within valid bounds and aligns with pages
		let maxOffset = contentWidth - scrollViewWidth
		let boundedDestination = min(max(destination, 0), maxOffset)

		if boundedDestination >= maxOffset * 0.95 {
			// If near the end, snap to the last possible position
			destination = maxOffset
		} else if boundedDestination <= scrollViewWidth * 0.05 {
			// If near the start, snap to the beginning
			destination = 0
		} else {
			if direction == .right {
				// For right-to-left scrolling, calculate from the right end
				let offsetFromRight = maxOffset - boundedDestination
				let pageFromRight = round(offsetFromRight / scrollViewWidth)
				destination = maxOffset - (pageFromRight * scrollViewWidth)
			} else {
				// For left-to-right scrolling, keep original behavior
				let pageNumber = round(boundedDestination / scrollViewWidth)
				destination = min(pageNumber * scrollViewWidth, maxOffset)
			}
		}

		target.rect.origin.x = destination
	}
}
