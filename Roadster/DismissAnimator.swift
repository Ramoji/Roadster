//
//  DismissAnimator.swift
//  Roadster
//
//  Created by A Ja on 11/7/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containverView = transitionContext.containerView
        containverView.alpha = 1
        let timeInterval = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: timeInterval, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                containverView.alpha = 0
            })
            
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }

}
