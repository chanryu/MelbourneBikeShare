//
//  MBSAnimationButton.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 7/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import UIKit

class MBSAnimationButton: UIButton {

    private var _animating: Bool = false

    func beingAnimation() {
        if _animating {
            return
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI * 2.0
        rotationAnimation.duration = 1
        rotationAnimation.autoreverses = false
        rotationAnimation.repeatCount = 99999
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        self.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
        _animating = true
    }
    
    func endAnimation() {
        if _animating {
            self.layer.removeAnimationForKey("rotationAnimation")
            _animating = false
        }
    }
}
