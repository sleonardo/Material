/*
* Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*	*	Redistributions of source code must retain the above copyright notice, this
*		list of conditions and the following disclaimer.
*
*	*	Redistributions in binary form must reproduce the above copyright notice,
*		this list of conditions and the following disclaimer in the documentation
*		and/or other materials provided with the distribution.
*
*	*	Neither the name of CosmicMind nor the names of its
*		contributors may be used to endorse or promote products derived from
*		this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit

public enum PulseAnimation {
	case none
	case center
	case centerWithBacking
	case centerRadialBeyondBounds
	case backing
	case point
	case pointWithBacking
}

internal extension MaterialAnimation {
	/**
     Triggers the expanding animation.
     - Parameter layer: Container CALayer.
     - Parameter visualLayer: A CAShapeLayer for the pulseLayer.
     - Parameter pulseColor: The UIColor for the pulse.
     - Parameter point: A point to pulse from.
     - Parameter width: Container width.
     - Parameter height: Container height.
     - Parameter duration: Animation duration.
     - Parameter pulseLayers: An Array of CAShapeLayers used in the animation.
     */
	internal static func pulseExpandAnimation(layer: CALayer, visualLayer: CALayer, pulseColor: UIColor, pulseOpacity: CGFloat, point: CGPoint, width: CGFloat, height: CGFloat, pulseLayers: inout Array<CAShapeLayer>, pulseAnimation: PulseAnimation) {
        guard .none != pulseAnimation else {
            return
        }
        
        let n = .center == pulseAnimation ? width < height ? width : height : width < height ? height : width
        
        let bLayer: CAShapeLayer = CAShapeLayer()
        let pLayer: CAShapeLayer = CAShapeLayer()
        
        bLayer.addSublayer(pLayer)
        pulseLayers.insert(bLayer, at: 0)
        visualLayer.addSublayer(bLayer)
        
        MaterialAnimation.animationDisabled(animations: {
            bLayer.frame = visualLayer.bounds
            pLayer.bounds = CGRect(x: 0, y: 0, width: n, height: n)
            
            switch pulseAnimation {
            case .center, .centerWithBacking, .centerRadialBeyondBounds:
                pLayer.position = CGPoint(x: width / 2, y: height / 2)
            default:
                pLayer.position = point
            }
            
            pLayer.cornerRadius = n / 2
            pLayer.backgroundColor = pulseColor.withAlphaComponent(pulseOpacity).cgColor
            pLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0, y: 0))
        })
        
        bLayer.setValue(false, forKey: "animated")
        
        let duration: CFTimeInterval = .center == pulseAnimation ? 0.16125 : 0.325
        
        switch pulseAnimation {
        case .centerWithBacking, .backing, .pointWithBacking:
            bLayer.add(MaterialAnimation.backgroundColor(color: pulseColor.withAlphaComponent(pulseOpacity / 2), duration: duration), forKey: nil)
        default:break
        }
        
        switch pulseAnimation {
        case .center, .centerWithBacking, .centerRadialBeyondBounds, .point, .pointWithBacking:
            pLayer.add(MaterialAnimation.scale(scale: 1, duration: duration), forKey: nil)
        default:break
        }
        
        MaterialAnimation.delay(time: duration, completion: {
            bLayer.setValue(true, forKey: "animated")
        })
	}
	
	/**
     Triggers the contracting animation.
     - Parameter layer: Container CALayer.
     - Parameter pulseColor: The UIColor for the pulse.
     - Parameter pulseLayers: An Array of CAShapeLayers used in the animation.
     */
	internal static func pulseContractAnimation(layer: CALayer, visualLayer: CALayer, pulseColor: UIColor, pulseLayers: inout Array<CAShapeLayer>, pulseAnimation: PulseAnimation) {
        guard let bLayer: CAShapeLayer = pulseLayers.popLast() else {
            return
        }
        
        let animated: Bool? = bLayer.value(forKey: "animated") as? Bool
        
        MaterialAnimation.delay(time: true == animated ? 0 : 0.15) {
            if let pLayer: CAShapeLayer = bLayer.sublayers?.first as? CAShapeLayer {
                let duration: CFTimeInterval = 0.325
                
                switch pulseAnimation {
                case .centerWithBacking, .backing, .pointWithBacking:
                    bLayer.add(MaterialAnimation.backgroundColor(color: pulseColor.withAlphaComponent(0), duration: 0.325), forKey: nil)
                default:break
                }
                
                switch pulseAnimation {
                case .center, .centerWithBacking, .centerRadialBeyondBounds, .point, .pointWithBacking:
                    pLayer.addAnimation(MaterialAnimation.animationGroup(animations: [
                        MaterialAnimation.scale(scale: .Center == pulseAnimation ? 1 : 1.325),
                        MaterialAnimation.backgroundColor(pulseColor.colorWithAlphaComponent(0))
                    ], duration: duration), forKey: nil)
                default:break
                }
                
                MaterialAnimation.delay(time: duration, completion: {
                    pLayer.removeFromSuperlayer()
                    bLayer.removeFromSuperlayer()
                })
            }
        }
	}
}
