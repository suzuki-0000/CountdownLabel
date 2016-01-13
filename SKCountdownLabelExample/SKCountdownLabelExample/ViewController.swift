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
    @IBOutlet weak var countdownLabel7: SKCountdownLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. normal
        countdownLabel1.setCountDownTime(30)
//        countdownLabel1.start()
        
        // 2. style
        countdownLabel2.setCountDownTime(30)
        countdownLabel2.textColor = .orangeColor()
        countdownLabel2.font = UIFont.boldSystemFontOfSize(40)
        countdownLabel2.timeFormat = "mm:ss"
//        countdownLabel2.start()
        
        // 3. get status
        countdownLabel3.setCountDownTime(30)
//        countdownLabel3.start()
        
        // 4. control countdown
        countdownLabel4.setCountDownTime(30)
//        countdownLabel4.start()
        
        // 5. control countdown
        countdownLabel5.setCountDownTime(5)
//        countdownLabel5.start() { [unowned self] in
//            self.countdownLabel5.text = "timer finished."
//        }
        
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
//        countdownLabel6.start(){
//            self.countdownLabel6.text = "timer finished."
//        }
        
        
        // 7. attributed text
        countdownLabel7.setCountDownTime(10)
        countdownLabel7.timeFormat = "ss"
        countdownLabel7.attrText = "hello \(SKCountdownLabel.replacementText)"
        countdownLabel7.attributes = [NSForegroundColorAttributeName: UIColor.redColor()]
        countdownLabel7.start()
        
        
//        timerExample13 = [[MZTimerLabel alloc] initWithLabel:_lblTimerExample13 andTimerType:MZTimerLabelTypeTimer];
//        [timerExample13 setCountDownTime:999];
//        NSString* text = @"timer here in text";
//        NSRange r = [text rangeOfString:@"here"];
//        
//        UIColor* fgColor = [UIColor redColor];
//        NSDictionary* attributesForRange = @{
//            NSForegroundColorAttributeName: fgColor,
//        };
//        timerExample13.attributedDictionaryForTextInRange = attributesForRange;
//        timerExample13.text = text;
//        timerExample13.textRange = r;
//        timerExample13.timeFormat = @"ss";
//        timerExample13.resetTimerAfterFinish = YES;
//        [timerExample13 start];
//        
//
        
    }
    
    // MARK: - countdownLabel3's IBAction
    @IBAction func getTimerCounted(sender: UIButton) {
        alert("\(countdownLabel3.timeRemaining)")
    }
    
    @IBAction func getTimerRemain(sender: UIButton) {
        alert("\(countdownLabel3.timeCounted)")
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

