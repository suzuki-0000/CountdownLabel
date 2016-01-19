//
//  ViewController2.swift
//  CountdownLabelExample
//
//  Created by suzuki keishi on 2016/01/19.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import Foundation
import CountdownLabel

class ViewController2: UIViewController {
    
    @IBOutlet weak var countdownLabel: CountdownLabel!
    
    override func viewDidLoad() {
        countdownLabel.setCountDownTime(60*60+10)
        countdownLabel.animationType = SKAnimationEffect.Evaporate
        countdownLabel.start()
    }
}

