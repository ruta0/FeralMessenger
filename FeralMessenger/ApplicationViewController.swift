//
//  ApplicationViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AudioToolbox


enum ResponseType {
    case normal
    case success
    case failure
}

extension UIViewController {
    
    // I should add an optional array parameters to store textFieldFlashers and textFieldJiterers
    func localTextResponder(_ responder: UILabel, for type: ResponseType, with message: String, completion: (() -> Void)? = nil) {
        print("localTextResponder - type \(type): \(message)")
        switch type {
        case .success:
            responder.textColor = UIColor.green
            responder.flash(delay: 5, message: message)
        case .failure:
            responder.textColor = UIColor.red
            responder.flash(delay: 5, message: message)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        case .normal:
            responder.textColor = UIColor.orange
            responder.flash(delay: 7, message: message)
        }
        completion?()
    }

}


extension UILabel {
    
    // I should add a flashing colour parameter into this
    func flash(delay: TimeInterval, message: String) {
        self.text = message
        UILabel.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }) { (completed: Bool) in
            if completed == true {
                UILabel.animate(withDuration: 0.3, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
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
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func jitter(repeatCount: Float) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.03
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint.init(x: self.center.x - 5.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint.init(x: self.center.x + 5.0, y: self.center.y))
        layer.add(animation, forKey: "position")
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


extension UIColor {
    
    static func mediumBlueGray() -> UIColor {
        return UIColor(red: 84/255, green: 84/255, blue: 94/255, alpha: 1)
    }
    
    static func mildBlueGray() -> UIColor {
        return UIColor(red: 105/255, green: 105/255, blue: 117.5/255, alpha: 1)
    }
    
    static func midNightBlack() -> UIColor {
        return UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
    }
    
    static func seaweedGreen() -> UIColor {
        return UIColor(red: 114/255, green: 143/255, blue: 65/255, alpha: 1)
    }
    
    static func opwrkScarlet() -> UIColor {
        return UIColor(red: 143/255, green: 50/255, blue: 55/255, alpha: 1)
    }
    
    static func candyWhite() -> UIColor {
        return UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
    
    static func mandarinOrange() -> UIColor {
        return UIColor(red: 189/255, green: 100/255, blue: 57/255, alpha: 1)
    }
    
    static func deepSeaBlue() -> UIColor {
        return UIColor(red: 40/255, green: 44/255, blue: 59/255, alpha: 1)
    }
    
    static func metallicGold() -> UIColor {
        return UIColor(red: 212/255, green: 175/255, blue: 55/255, alpha: 1)
    }
    
    static func lightBlue() -> UIColor {
        return UIColor(red: 232/255, green: 236/255, blue: 241/255, alpha: 1)
    }
    
    /// Apple's custom colour for highlighted items
    static func miamiBlue() -> UIColor {
        return UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1)
    }
    
}













