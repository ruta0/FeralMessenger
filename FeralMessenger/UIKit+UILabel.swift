//
//  UILabel.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


extension UILabel {
    
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
    
}
