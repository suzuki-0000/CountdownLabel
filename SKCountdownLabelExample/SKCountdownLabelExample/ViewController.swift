//
//  ViewController.swift
//  SKCountdownLabelExample
//
//  Created by suzuki keishi on 2016/01/06.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit
import SKCountdownLabel

class ViewController: UIViewController {

    @IBOutlet weak var countdownLabel1: SKCountdownLabel!
    @IBOutlet weak var countdownLabel2: SKCountdownLabel!
    @IBOutlet weak var countdownLabel3: SKCountdownLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 1. normal
        countdownLabel1.setCountDownTime(30)
        countdownLabel1.start()
        
        // 2. style
        countdownLabel2.setCountDownTime(30)
        countdownLabel2.textColor = .orangeColor()
        countdownLabel2.font = UIFont.boldSystemFontOfSize(40)
        countdownLabel2.start()
        
        // 3. get status
        countdownLabel3.setCountDownTime(30)
        countdownLabel3.start()
        
        
    }
    
    // MARK: - countdownLabel3's IBAction
    @IBAction func getTimerCounted(sender: UIButton) {
        countdownLabel3.find
    }
    
    @IBAction func getTimerRemain(sender: UIButton) {
    }
    
}

