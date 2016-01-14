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
    @IBOutlet weak var countdownLabelAnvil: SKCountdownLabel!
    @IBOutlet weak var countdownLabelBurn: SKCountdownLabel!
    @IBOutlet weak var countdownLabelEvaporate: SKCountdownLabel!
    @IBOutlet weak var countdownLabelFall: SKCountdownLabel!
    @IBOutlet weak var countdownLabelPixelate: SKCountdownLabel!
    @IBOutlet weak var countdownLabelScale: SKCountdownLabel!
    @IBOutlet weak var countdownLabelSparkle: SKCountdownLabel!
    @IBOutlet weak var countdownLabel2: SKCountdownLabel!
    @IBOutlet weak var countdownLabel3: SKCountdownLabel!
    @IBOutlet weak var countdownLabel4: SKCountdownLabel!
    @IBOutlet weak var countdownLabel5: SKCountdownLabel!
    @IBOutlet weak var countdownLabel6: SKCountdownLabel!
    @IBOutlet weak var countdownLabel7: SKCountdownLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. normal
        countdownLabel1.setCountDownTime(30)
        countdownLabel1.start()
        
        // option animation ( using LTMorphing inside )
        countdownLabelAnvil.setCountDownTime(30)
        countdownLabelAnvil.animationType = .Anvil
        countdownLabelAnvil.start()
        
        countdownLabelBurn.setCountDownTime(30)
        countdownLabelBurn.animationType = .Burn
        countdownLabelBurn.start()
        
        countdownLabelEvaporate.setCountDownTime(30)
        countdownLabelEvaporate.animationType = .Evaporate
        countdownLabelEvaporate.start()
        
        countdownLabelFall.setCountDownTime(30)
        countdownLabelFall.animationType = .Fall
        countdownLabelFall.start()
        
        countdownLabelPixelate.setCountDownTime(30)
        countdownLabelPixelate.animationType = .Pixelate
        countdownLabelPixelate.start()
        
        countdownLabelScale.setCountDownTime(30)
        countdownLabelScale.animationType = .Scale
        countdownLabelScale.start()
        
        countdownLabelSparkle.setCountDownTime(30)
        countdownLabelSparkle.animationType = .Sparkle
        countdownLabelSparkle.start()
        
        // 2. style
        countdownLabel2.setCountDownTime(3)
        countdownLabel2.textColor = .orangeColor()
        countdownLabel2.font = UIFont.boldSystemFontOfSize(40)
        countdownLabel2.start()
        
        // 3. get status
        countdownLabel3.setCountDownTime(30)
        countdownLabel3.start()
        
        // 4. control countdown
        countdownLabel4.setCountDownTime(30)
        countdownLabel4.start()
        
        // 5. control countdown
        countdownLabel5.setCountDownTime(5)
        countdownLabel5.start() { [unowned self] in
            self.countdownLabel5.text = "timer finished."
        }
        
        // 6. control countdown
        countdownLabel6.setCountDownTime(5)
        countdownLabel6.then(3){ [unowned self] in
            self.countdownLabel6.textColor = .brownColor()
        }
        countdownLabel6.then(2){ [unowned self] in
            self.countdownLabel6.textColor = .greenColor()
        }
        countdownLabel6.then(1){ [unowned self] in
            self.countdownLabel6.textColor = .redColor()
        }
        countdownLabel6.start(){
            self.countdownLabel6.text = "timer finished."
        }
       
        // 7. attributed text
        countdownLabel7.setCountDownTime(10)
        countdownLabel7.timeFormat = "ss"
        countdownLabel7.timerInText = SKTimerInText(text: "timer here in text", replacement: "here")
        countdownLabel7.start() {
            self.countdownLabel7.text = "timer finished."
        }
    }
    
    // MARK: - countdownLabel3's IBAction
    @IBAction func getTimerCounted(sender: UIButton) {
        alert("\(countdownLabel3.timeCounted)")
    }
    
    @IBAction func getTimerRemain(sender: UIButton) {
        alert("\(countdownLabel3.timeRemaining)")
    }
    
    // MARK: - countdownLabel4's IBAction
    @IBAction func controlStartStop(sender: UIButton) {
        if countdownLabel4.paused {
            countdownLabel4.start()
            sender.setTitle("pause", forState: .Normal)
        } else {
            countdownLabel4.pause()
            sender.setTitle("start", forState: .Normal)
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

