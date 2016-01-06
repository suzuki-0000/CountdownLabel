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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        countdownLabel1.setCountDownTime(30)
        countdownLabel1.start()
    }
}

