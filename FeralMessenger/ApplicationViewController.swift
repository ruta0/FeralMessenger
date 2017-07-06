//
//  ApplicationViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AudioToolbox


// MARK: - Alert event handling

enum ResponseType {
    case normal
    case success
    case failure
}


extension URL {
    
    static var termsUrl = URL(string: "https://sheltered-ridge-89457.herokuapp.com/terms")
    
}


extension UIViewController {
    
    // Alert for error / success handling
    func alertRespond(_ handler: UILabel, with responders: [UITextField]?, for type: ResponseType, with message: String, completion: (() -> Void)? = nil) {
        print("localTextResponder - type \(type): \(message)")
        switch type {
        case .success:
            DispatchQueue.main.async(execute: { 
                handler.flash(delay: 5, duration: 0.3, message: message, color: UIColor.green)
            })
        case .failure:
            DispatchQueue.main.async(execute: { 
                handler.flash(delay: 5, duration: 0.3, message: message, color: UIColor.red)
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                if let responders = responders {
                    for responder in responders {
                        responder.jitter(repeatCount: 5, duration: 0.03)
                    }
                }
            })
        case .normal:
            DispatchQueue.main.async(execute: { 
                handler.flash(delay: 6, duration: 0.3, message: message, color: UIColor.orange)
            })
        }
        completion?()
    }

}


extension UILabel {
    
    // Call this method with your handler: UILabel
    func flash(delay: TimeInterval, duration: TimeInterval, message: String, color: UIColor) {
        self.text = message
        self.textColor = color
        UILabel.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }) { (completed: Bool) in
            if completed == true {
                UILabel.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
}


extension UIView {

    func enableParallaxMotion(magnitude: Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        addMotionEffect(group)
    }
    
    func jitter(repeatCount: Float, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint.init(x: self.center.x - 5.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint.init(x: self.center.x + 5.0, y: self.center.y))
        layer.add(animation, forKey: "position")
    }
    
}


// MARK: - Color customization

extension UIColor {
    
    static var midNightBlack: UIColor {
        return UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
    }
    
    static var seaweedGreen: UIColor {
        return UIColor(red: 114/255, green: 143/255, blue: 65/255, alpha: 1)
    }
    
    static var opwrkScarlet: UIColor {
        return UIColor(red: 143/255, green: 50/255, blue: 55/255, alpha: 1)
    }
    
    static var candyWhite: UIColor {
        return UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
    
    static var mandarinOrange: UIColor {
        return UIColor(red: 189/255, green: 100/255, blue: 57/255, alpha: 1)
    }
    
    static var metallicGold: UIColor {
        return UIColor(red: 212/255, green: 175/255, blue: 55/255, alpha: 1)
    }
    
    static var deepSeaBlue: UIColor {
        return UIColor(red: 40/255, green: 44/255, blue: 59/255, alpha: 1)
    }
    
    static var mediumBlueGray: UIColor {
        return UIColor(red: 84/255, green: 84/255, blue: 94/255, alpha: 1)
    }
    
    static var mildBlueGray: UIColor {
        return UIColor(red: 105/255, green: 105/255, blue: 117.5/255, alpha: 1)
    }
    
    static var lightBlue: UIColor {
        return UIColor(red: 232/255, green: 236/255, blue: 241/255, alpha: 1)
    }
    
    /// Apple's custom colour for highlighted items
    static var miamiBlue: UIColor {
        return UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1)
    }
    
}













