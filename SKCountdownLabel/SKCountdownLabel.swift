//
//  SKCountdownLabel.swift
//  SKCountdownLabel
//
//  Created by suzuki keishi on 2016/01/06.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

@objc protocol SKCountdownLabelDelegate {
    func countdownFinished()
    func countingTo(time: NSTimeInterval)
}


public extension NSTimeInterval {
    var int: Int {
        return Int(self)
    }
}

public class SKCountdownLabel: UILabel{
    
    public typealias CountdownCompletion = () -> ()?
    public typealias Execution = () -> ()
    
    let defaultTimeFormat = "HH:mm:ss"
    let defaultFireIntervalNormal = 0.1
    let defaultFireIntervalHighUse = 0.01
    let date1970 = NSDate(timeIntervalSince1970: 0)
    
    weak var delegate: SKCountdownLabelDelegate?
    
    public lazy var dateFormatter: NSDateFormatter = { [unowned self] in
        let df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "ja_JP")
        df.timeZone = NSTimeZone(name: "GMT")
        df.dateFormat = self.timeFormat
        return df
    }()
    
    public var timeCounted:NSTimeInterval {
        var timeCounted = NSDate().timeIntervalSinceDate(currentCountDate)
        if pausedDate != nil {
            let pausedCountedTime = NSDate().timeIntervalSinceDate(pausedDate)
            timeCounted -= pausedCountedTime
        }
        return timeCounted < 0 ? 0 : timeCounted
    }
    
    public var timeRemaining: NSTimeInterval {
        return currentTimeInterval - floor(timeCounted)
    }
    
    public var timeDiff: NSTimeInterval {
        let currentDate = NSDate()
        let diffTime = currentDate.timeIntervalSinceDate(currentCountDate)
        return diffTime
    }
    
    public var isEndOfTimer: Bool {
        return timeDiff >= currentTimeInterval
    }
    
    public var timer: NSTimer!
    public var timeFormat = "HH:mm:ss"
    public var textRange: NSRange = NSRange()
    public var attributedDictionaryForTextInRange: NSDictionary!
    
    // status: origin
    private var originCountDate: NSDate = NSDate()
    private var originTimeInterval: NSTimeInterval = 0
    // status: current
    private var currentCountDate: NSDate = NSDate()
    private var currentTimeInterval: NSTimeInterval = 0
    private var currentDiffDate: NSDate!
    // status: control
    public var paused: Bool = false
    private var pausedDate: NSDate!
    public var counting: Bool = false
    public var finished: Bool = false {
        didSet {
            if finished {
                paused = false
                counting = false
            }
        }
    }
    
    // user controls
    private var completion: CountdownCompletion?
    public var thens = [NSTimeInterval: Execution]()
    public var lessThans = [NSTimeInterval: Execution]()
    public var moreThans = [NSTimeInterval: Execution]()
    
    private var originalTime: Int {
        return Int(originTimeInterval)
    }
    
    // MARK: - Initialize
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // MARK: - Setter Methods
    
    public func setCountDownTime(time: NSTimeInterval) {
        setCountDownTime(NSDate(), originTime: time)
    }
    
    public func setCountDownTime(origin: NSDate, originTime: NSTimeInterval) {
        originCountDate = origin
        originTimeInterval = originTime
        currentCountDate = origin
        currentTimeInterval = originTime
        currentDiffDate = date1970.dateByAddingTimeInterval(originTimeInterval)
        
        updateLabel()
    }
    
//    public func setCountDownDate(date: NSDate){
//        let timeLeft = date.timeIntervalSinceDate(date)
//        if timeLeft > 0 {
//            originTimeInterval = timeLeft
//            currentDiffDate = date1970.dateByAddingTimeInterval(timeLeft)
//        } else {
//            originTimeInterval = 0
//            currentDiffDate = date1970.dateByAddingTimeInterval(0)
//        }
//        
//        updateLabel()
//    }
    
    func updateLabel() {
        if paused {
            text = dateFormatter.stringFromDate(currentDiffDate)
        }
        
        // start new timer
        
        delegate?.countingTo(timeRemaining)
        
        thens.forEach { k,v in
            if k.int == timeRemaining.int {
                debugPrint("inside !!!!")
                v()
                thens[k] = nil
            }
        }
        
        if isEndOfTimer {
            text = dateFormatter.stringFromDate(date1970.dateByAddingTimeInterval(0))
        } else {
            text = dateFormatter.stringFromDate(currentDiffDate.dateByAddingTimeInterval(timeDiff * -1))
        }
        
        if isEndOfTimer {
            delegate?.countdownFinished()
            completion?()
            dispose()
        }
//        if textRange.length > 0 {
//            if attributedDictionaryForTextInRange != nil {
//                
//                let attrTextInRange = NSAttributedString(string: dateFormatter.stringFromDate(showDate), attributes: attributedDictionaryForTextInRange as? [String : AnyObject])
//                
//                let attributedString = NSMutableAttributedString(string: text!)
//                attributedString.replaceCharactersInRange(textRange, withAttributedString: attrTextInRange)
//                
//                attributedText = attributedString
//            } else {
//                
//                let labelText = (text! as NSString).stringByReplacingCharactersInRange(textRange, withString: dateFormatter.stringFromDate(showDate))
//                
//                text = labelText
//            }
//            
//            
//        } else  {
//        }
//        
    }
}


// MARK: - Public
public extension SKCountdownLabel {
    func start(completion: CountdownCompletion? = nil){
        debugPrint("[start]start")
        
        // set completion if needed
        self.completion = completion
        
        // reset timer if validate
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        // timer format
        if timeFormat.rangeOfString("SS")?.underestimateCount() > 0 {
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalHighUse, target: self, selector: "updateLabel:", userInfo: nil, repeats: true)
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalNormal, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
        }
        
        //TODO : what
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        // pause
        if paused {
            // change date
            let pastedTime = pausedDate.timeIntervalSinceDate(currentCountDate)
            currentCountDate = NSDate().dateByAddingTimeInterval(-pastedTime)
            
            // reset pause
            pausedDate = nil
            paused = false
            
        }
        
        debugPrint("[start]end")
        
        // fire!
        counting = true
        timer.fire()
    }
    
    func pause(){
        if paused {
            return
        }
        
        // invalidate timer
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        // stop counting
        counting = false
        paused = true
        
        // reset
        pausedDate = NSDate()
    }
    
    func reset(){
        // reset if finished
        finished = false
        
        currentCountDate = NSDate()
        currentDiffDate = date1970.dateByAddingTimeInterval(originTimeInterval)
        currentTimeInterval = originTimeInterval
        
        updateLabel()
    }
    
    func dispose(){
        // invalidate timer
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        // stop counting
        finished = true
        
        pausedDate = nil
    }
    
    func addTimeCountedByTime(time: NSTimeInterval) {
        currentTimeInterval = time + currentTimeInterval
        currentDiffDate = date1970.dateByAddingTimeInterval(currentTimeInterval)
        
        updateLabel()
    }
    
    func then(targetTime: NSTimeInterval, completion: () -> ()) -> Self{
        let t = originTimeInterval - (originTimeInterval - targetTime)
        guard t > 0 else {
            return self
        }
        
        debugPrint(t)
        thens[t] = completion
        return self
    }
}

// MARK: - private
private extension SKCountdownLabel {
    func setup(){
        timeFormat = defaultTimeFormat
    }
}
