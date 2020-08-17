//
//  WavesLayer.swift
//  speechAssistant
//
//  Created by Vishal on 11/08/20.
//

import Foundation
public class WavesLayer:UIView {
	
	private weak var displayLink: CADisplayLink?
	private var startTime: CFTimeInterval = 0
	
	private let shapeLayer: CAShapeLayer = {
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor(
			red: 51/255, green: 165/255, blue: 50/255, alpha: 1.0).cgColor
		shapeLayer.opacity = 0.2
		return shapeLayer
	}()
	
	private let shapeLayer1: CAShapeLayer = {
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor(
			red: 51/255, green: 165/255, blue: 50/255, alpha: 1.0).cgColor
		shapeLayer.opacity = 0.2
		return shapeLayer
	}()
	
	private let shapeLayer2: CAShapeLayer = {
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor(
			red: 51/255, green: 165/255, blue: 50/255, alpha: 1.0).cgColor
		shapeLayer.opacity = 0.5
		return shapeLayer
	}()
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		self.layer.addSublayer(shapeLayer)
		self.layer.addSublayer(shapeLayer1)
		self.layer.addSublayer(shapeLayer2)
		startDisplayLink()
	}
	
	func startDisplayLink() {
		startTime = CACurrentMediaTime()
		self.displayLink?.invalidate()
		let displayLink = CADisplayLink(target: self,
																		selector:#selector(handleDisplayLink(_:)))
		displayLink.add(to: .main, forMode: .common)
		self.displayLink = displayLink
	}
	
	func stopDisplayLink() {
		displayLink?.invalidate()
	}
	
	@objc func handleDisplayLink(_ displayLink: CADisplayLink) {
		let elapsed = CACurrentMediaTime() - startTime
		shapeLayer.path = wave(at: elapsed/2.5, amplitude: CGFloat(20),
													 direction: true).cgPath
		shapeLayer1.path = wave(at: elapsed/3.2, amplitude: CGFloat(20),
														direction: false).cgPath
		shapeLayer2.path = wave(at: elapsed, amplitude: CGFloat(8),
														direction: false).cgPath
	}
	
	private func wave(at elapsed: Double, amplitude:CGFloat,
										direction: Bool) -> UIBezierPath {
		let elapsed = CGFloat(elapsed)
		let centerY = self.bounds.midY
		let amplitude = CGFloat(amplitude)
		func f(_ x: CGFloat) -> CGFloat {
			if(direction) {
				return sin((x - elapsed) * 2.5 * .pi) * amplitude + centerY
			}
			return sin((x + elapsed) * 2.5 * .pi) * amplitude + centerY
		}
		let path = UIBezierPath()
		let steps = Int(self.bounds.width / 10)
		path.move(to:CGPoint(x: 0, y: f(0)))
		for step in 1 ... steps {
			let x = CGFloat(step) / CGFloat(steps)
			path.addLine(to: CGPoint(x: x * self.bounds.width, y: f(x)))
		}
		path.addLine(to: CGPoint(x: self.bounds.width, y: self.frame.size.height))
		path.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
		return path
	}
	
}
