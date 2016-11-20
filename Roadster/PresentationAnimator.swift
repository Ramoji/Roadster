//
//  PresentationAnimator.swift
//  Roadster
//
//  Created by A Ja on 11/6/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)
        let toView = transitionContext.view(forKey: .to)
        let containerView = transitionContext.containerView
        toView?.frame = transitionContext.finalFrame(for: toViewController!)
        containerView.addSubview(toView!)
        toView?.alpha = 0
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIViewKeyframeAnimationOptions.calculationModeCubic, animations: {
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                toView?.alpha = 1
            })
        }, completion: {
            finished in
            transitionContext.completeTransition(finished)
        })
    }

}
