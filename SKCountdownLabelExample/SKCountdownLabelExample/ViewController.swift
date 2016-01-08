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
    @IBOutlet weak var countdownLabel4: SKCountdownLabel!
    @IBOutlet weak var countdownLabel5: SKCountdownLabel!
    @IBOutlet weak var countdownLabel6: SKCountdownLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 1. normal
        countdownLabel1.setCountDownTime(30)
        countdownLabel1.start()
        
        // 2. style
        countdownLabel2.setCountDownTime(30)
        countdownLabel2.textColor = .orangeColor()
        countdownLabel2.font = UIFont.boldSystemFontOfSize(40)
//        countdownLabel2.start()
        
        // 3. get status
        countdownLabel3.setCountDownTime(30)
//        countdownLabel3.start()
        
        // 4. control countdown
        countdownLabel4.setCountDownTime(30)
        countdownLabel4.start()
        
        // 5. control countdown
        countdownLabel5.setCountDownTime(30)
//        countdownLabel5.start() { [unowned self] in
//            self.countdownLabel5.text = "timer finished."
//        }
        
        // 6. control countdown
        countdownLabel6.setCountDownTime(30)
        countdownLabel6.then(25){ [unowned self] in
            self.alert("timer goes 25.")
        }
        countdownLabel6.then(20){ [unowned self] in
            self.alert("timer goes 20.")
        }
//        countdownLabel6.start()
    }
    
    // MARK: - countdownLabel3's IBAction
    @IBAction func getTimerCounted(sender: UIButton) {
        debugPrint(countdownLabel3.timeRemaining)
    }
    
    @IBAction func getTimerRemain(sender: UIButton) {
        debugPrint(countdownLabel3.timeCounted)
    }
    
    // MARK: - countdownLabel4's IBAction
    @IBAction func controlStartStop(sender: UIButton) {
        if countdownLabel4.counting {
            countdownLabel4.pause()
            sender.setTitle("start", forState: .Normal)
        } else {
            countdownLabel4.start()
            sender.setTitle("pause", forState: .Normal)
        }
    }
    
    @IBAction func controlReset(sender: UIButton) {
        countdownLabel4.reset()
        countdownLabel4.start()
    }
    
    @IBAction func minus(sender: UIButton) {
        countdownLabel4.addTimeCountedByTime(-2)
    }
    
    @IBAction func plus(sender: UIButton) {
        countdownLabel4.addTimeCountedByTime(2)
    }
}

extension ViewController {
    func alert(title: String){
        let vc = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(vc, animated: true, completion: nil)
    }
}

