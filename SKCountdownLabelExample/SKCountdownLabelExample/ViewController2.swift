//
//  ViewController2.swift
//  SKCountdownLabelExample
//
//  Created by suzuki keishi on 2016/01/19.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import Foundation
import SKCountdownLabel

class ViewController2: UIViewController {
    
    @IBOutlet weak var countdownLabel: SKCountdownLabel!
    
    override func viewDidLoad() {
        countdownLabel.setCountDownTime(60*60+10)
        countdownLabel.animationType = SKAnimationEffect.Evaporate
        countdownLabel.start()
    }
}

