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
    
    public typealias SKCountdownCompletion = () -> ()?
    public typealias SKCountdownExecution = () -> ()
    private let defaultFireIntervalNormal = 0.1
    private let defaultFireIntervalHighUse = 0.01
    private let date1970 = NSDate(timeIntervalSince1970: 0)
    
    // conputed property
    public var dateFormatter: NSDateFormatter {
        let df = NSDateFormatter()
        df.locale = NSLocale.currentLocale()
        df.timeZone = NSTimeZone(name: "GMT")
        df.dateFormat = timeFormat
        return df
    }
    
    public var timeCounted:NSTimeInterval {
        var timeCounted = NSDate().timeIntervalSinceDate(currentCountDate)
        
        if pausedDate != nil {
            let pausedCountedTime = NSDate().timeIntervalSinceDate(pausedDate)
            timeCounted -= pausedCountedTime
        }
        return timeCounted < 0 ? 0 : timeCounted
    }
    
    public var timeRemaining: NSTimeInterval {
        return round(currentTimeInterval) - round(timeCounted)
    }
    
    public var timeDiff: NSTimeInterval {
        let currentDate = NSDate()
        let diffTime = currentDate.timeIntervalSinceDate(currentCountDate)
        return diffTime
    }
    
    public var isEndOfTimer: Bool {
        return timeDiff >= currentTimeInterval
    }
    
    weak var delegate: SKCountdownLabelDelegate?
    
    // timer
    public var timeFormat = "HH:mm:ss"
    private var timer: NSTimer!
    // status: origin
    private var originTimeInterval: NSTimeInterval = 0
    // status: current
    private var currentCountDate: NSDate = NSDate()
    private var currentTimeInterval: NSTimeInterval = 0
    private var currentDiffDate: NSDate!
    // status: style
    public var timerInText: SKTimerInText! {
        didSet {
            range = (timerInText.text as NSString).rangeOfString(timerInText.replacement)
        }
    }
    private var range: NSRange!
    // status: control
    private var pausedDate: NSDate!
    public var paused: Bool = false
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
    private var completion: SKCountdownCompletion?
    public var thens = [NSTimeInterval: SKCountdownExecution]()
    
    private var originalTime: Int {
        return Int(originTimeInterval)
    }
    
    // MARK: - Initialize
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(frame: CGRect, time: NSTimeInterval) {
        self.init(frame: frame)
        setCountDownTime(time)
    }
    
    // MARK: - Setter Methods
    
    public func setCountDownTime(time: NSTimeInterval) {
        setCountDownTime(NSDate(), originTime: time)
    }
    
    public func setCountDownTime(origin: NSDate, originTime: NSTimeInterval) {
        originTimeInterval = originTime
        currentCountDate = origin
        currentTimeInterval = originTime
        currentDiffDate = date1970.dateByAddingTimeInterval(originTimeInterval)
        
        updateLabel()
    }
    
    public func setCountDownDate(origin: NSDate){
        setCountDownDate(NSDate(), originDate: origin)
    }
    
    public func setCountDownDate(origin: NSDate, originDate: NSDate) {
        originTimeInterval = originDate.timeIntervalSinceDate(origin)
        currentCountDate = origin
        currentTimeInterval = originDate.timeIntervalSinceDate(origin)
        currentDiffDate = date1970.dateByAddingTimeInterval(originTimeInterval)
        
        updateLabel()
    }
    
    func updateLabel() {
        if paused {
            text = dateFormatter.stringFromDate(currentDiffDate)
        }
        
        // delegate
        delegate?.countingTo(timeRemaining)
        
        // then function execute if needed
        thens.forEach { k,v in
            if k.int == timeRemaining.int {
                v()
                thens[k] = nil
            }
        }
        
        // update text
        updateText()
        
        // if end of timer
        if isEndOfTimer {
            delegate?.countdownFinished()
            completion?()
            dispose()
        }
    }
}

// MARK: - Public
public extension SKCountdownLabel {
    func start(completion: (()->())? = nil){
        debugPrint("[start]start")
        
        // set completion if needed
        self.completion = completion
        
        // create timer
        createTimer()
        
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
        disposeTimer()
        
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
        
        thens[t] = completion
        return self
    }
}

// MARK: - private
private extension SKCountdownLabel {
    func updateText() {
        if let timerInText = timerInText {
            let attrTextInRange = NSAttributedString(string: dateFormatter.stringFromDate(currentDiffDate.dateByAddingTimeInterval(timeDiff * -1)), attributes: timerInText.attributes)
            let attributedString = NSMutableAttributedString(string: timerInText.text)
            attributedString.replaceCharactersInRange(range, withAttributedString: attrTextInRange)
            
            attributedText = attributedString
            text = attributedString.string
        } else {
            text = dateFormatter.stringFromDate(currentDiffDate.dateByAddingTimeInterval(timeDiff * -1))
        }
    }
    
    func createTimer(){
        // dispose
        disposeTimer()
        
        // create
        if timeFormat.rangeOfString("SS")?.underestimateCount() > 0 {
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalHighUse, target: self, selector: "updateLabel:", userInfo: nil, repeats: true)
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalNormal, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
        }
    }
    
    func disposeTimer(){
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func dispose(){
        // reset
        text = nil
        pausedDate = nil
        
        // invalidate timer
        disposeTimer()
        
        // stop counting
        finished = true
        
    }
}

public class SKTimerInText: NSObject {
    private let text: String
    private let replacement: String
    private let attributes: [String: AnyObject]?
   
    public init(text: String, replacement: String, attributes: [String: AnyObject]? = nil) {
        self.text = text
        self.replacement = replacement
        self.attributes = attributes
    }
}