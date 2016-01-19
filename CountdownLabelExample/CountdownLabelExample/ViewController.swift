//
//  ViewController.swift
//  CountdownLabelExample
//
//  Created by suzuki keishi on 2016/01/06.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit
import CountdownLabel

class ViewController: UIViewController {

    @IBOutlet weak var countdownLabel1: CountdownLabel!
    @IBOutlet weak var countdownLabelAnvil: CountdownLabel!
    @IBOutlet weak var countdownLabelBurn: CountdownLabel!
    @IBOutlet weak var countdownLabelEvaporate: CountdownLabel!
    @IBOutlet weak var countdownLabelFall: CountdownLabel!
    @IBOutlet weak var countdownLabelPixelate: CountdownLabel!
    @IBOutlet weak var countdownLabelScale: CountdownLabel!
    @IBOutlet weak var countdownLabelSparkle: CountdownLabel!
    @IBOutlet weak var countdownLabel2: CountdownLabel!
    @IBOutlet weak var countdownLabel3: CountdownLabel!
    @IBOutlet weak var countdownLabel4: CountdownLabel!
    @IBOutlet weak var countdownLabel5: CountdownLabel!
    @IBOutlet weak var countdownLabel6: CountdownLabel!
    @IBOutlet weak var countdownLabel7: CountdownLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. normal
        countdownLabel1.setCountDownTime(60*60+10)
        countdownLabel1.start()
        
        // option animation ( using LTMorphing inside )
        countdownLabelAnvil.setCountDownTime(60*60+10)
        countdownLabelAnvil.animationType = .Anvil
        countdownLabelAnvil.start()
        
        countdownLabelBurn.setCountDownTime(60*60+10)
        countdownLabelBurn.animationType = .Burn
        countdownLabelBurn.start()
        
        countdownLabelEvaporate.setCountDownTime(60*60+10)
        countdownLabelEvaporate.animationType = .Evaporate
        countdownLabelEvaporate.start()
        
        countdownLabelFall.setCountDownTime(60*60+10)
        countdownLabelFall.animationType = .Fall
        countdownLabelFall.start()
        
        countdownLabelPixelate.setCountDownTime(60*60+10)
        countdownLabelPixelate.animationType = .Pixelate
        countdownLabelPixelate.start()
        
        countdownLabelScale.setCountDownTime(60*60+10)
        countdownLabelScale.animationType = .Scale
        countdownLabelScale.start()
        
        countdownLabelSparkle.setCountDownTime(60*60+10)
        countdownLabelSparkle.animationType = .Sparkle
        countdownLabelSparkle.start()
        
        // 2. style
        countdownLabel2.setCountDownTime(60*60+15)
        countdownLabel2.animationType = .Evaporate
        countdownLabel2.textColor = .orangeColor()
        countdownLabel2.font = UIFont(name:"Courier", size:UIFont.labelFontSize())
        countdownLabel2.start()
        
        // 3. get status
        countdownLabel3.setCountDownTime(30)
        countdownLabel3.animationType = .Sparkle
        countdownLabel3.start()
        
        // 4. control countdown
        countdownLabel4.setCountDownTime(30)
        countdownLabel4.animationType = .Pixelate
        countdownLabel4.start()
        
        // 5. control countdown
        countdownLabel5.setCountDownTime(10)
        countdownLabel5.animationType = .Pixelate
        countdownLabel5.countdownDelegate = self
        countdownLabel5.start() { [unowned self] in
            self.countdownLabel5.text = "timer finished."
        }
        
        // 6. control countdown
        countdownLabel6.setCountDownTime(30)
        countdownLabel5.animationType = .Scale
countdownLabel6.then(10) { [unowned self] in
    self.countdownLabel6.animationType = .Pixelate
    self.countdownLabel6.textColor = .greenColor()
}
countdownLabel6.then(5) { [unowned self] in
    self.countdownLabel6.animationType = .Sparkle
    self.countdownLabel6.textColor = .yellowColor()
}
countdownLabel6.start() {
    self.countdownLabel6.textColor = .whiteColor()
}
       
        // 7. attributed text
        countdownLabel7.setCountDownTime(30)
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
        if countdownLabel4.isPaused {
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

extension ViewController: CountdownLabelDelegate {
    func countdownFinished() {
        debugPrint("countdownFinished at delegate.")
    }
    
    func countingAt(timeCounted timeCounted: NSTimeInterval, timeRemaining: NSTimeInterval) {
        debugPrint("time counted at delegate=\(timeCounted)")
        debugPrint("time remaining at delegate=\(timeRemaining)")
    }
    
}

extension ViewController {
    func alert(title: String) {
        let vc = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(vc, animated: true, completion: nil)
    }
}

