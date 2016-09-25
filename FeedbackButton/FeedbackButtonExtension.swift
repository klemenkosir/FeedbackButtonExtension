//
//  FeedbackButtonExtension.swift
//  FeedbackButton
//
//  Created by Klemen Kosir on 23. 09. 16.
//  Copyright © 2016 Klemen Kosir. All rights reserved.
//

import UIKit

fileprivate var tapticFeedbackKey: UInt8 = 0
fileprivate var didClickKey: UInt8 = 0
fileprivate var feedbackThresholdKey: UInt8 = 0
fileprivate var feedbackGeneratorKey: UInt8 = 0
fileprivate var touchKey: UInt8 = 0

extension UIButton {
	
	@IBInspectable var tapticFeedback: Bool {
		get {
			return objc_getAssociatedObject(self, &tapticFeedbackKey) as? Bool ?? false
		}
		set(newValue) {
			objc_setAssociatedObject(self, &tapticFeedbackKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	@IBInspectable var feedbackThreshold: CGFloat {
		get {
			return objc_getAssociatedObject(self, &feedbackThresholdKey) as? CGFloat ?? 0.0
		}
		set(newValue) {
			objc_setAssociatedObject(self, &feedbackThresholdKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	fileprivate var didClick: Bool {
		get {
			return objc_getAssociatedObject(self, &didClickKey) as? Bool ?? false
		}
		set(newValue) {
			objc_setAssociatedObject(self, &didClickKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	fileprivate var feedbackGenerator: UIImpactFeedbackGenerator? {
		get {
			return objc_getAssociatedObject(self, &feedbackGeneratorKey) as? UIImpactFeedbackGenerator
		}
		set(newValue) {
			objc_setAssociatedObject(self, &feedbackGeneratorKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	fileprivate var touch: UITouch? {
		get {
			return objc_getAssociatedObject(self, &touchKey) as? UITouch
		}
		set(newValue) {
			objc_setAssociatedObject(self, &touchKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	open override func didMoveToSuperview() {
		let syncLink = CADisplayLink(target: self, selector: #selector(self.updateForce))
		syncLink.add(to: RunLoop.main, forMode: .commonModes)
		super.didMoveToSuperview()
	}
	
	func updateForce() {
		guard let t = touch else {
			if didClick {
				feedbackGenerator?.impactOccurred()
				didClick = false
			}
			return
		}
		if (feedbackThreshold <= 0 || t.force > feedbackThreshold) && !didClick {
			feedbackGenerator?.impactOccurred()
			feedbackGenerator?.prepare()
			didClick = true
		}
		else if t.force <= feedbackThreshold && didClick {
			feedbackGenerator?.impactOccurred()
			feedbackGenerator?.prepare()
			didClick = false
		}
	}
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if feedbackGenerator == nil {
			feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
		}
		feedbackGenerator?.prepare()
		touch = touches.first
		super.touchesBegan(touches, with: event)
	}
	
	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		touch = nil
		super.touchesEnded(touches, with: event)
	}
	
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		touch = nil
		super.touchesCancelled(touches, with: event)
	}
	
}
