//
//  SKCountdownLabel.swift
//  SKCountdownLabel
//
//  Created by suzuki keishi on 2016/01/06.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit
import LTMorphingLabel

@objc public protocol SKCountdownLabelDelegate {
    optional func countdownFinished()
    optional func countingAt(timeCounted timeCounted: NSTimeInterval, timeRemaining: NSTimeInterval)
}

public extension NSTimeInterval {
    var int: Int {
        return Int(self)
    }
}

public class SKCountdownLabel: LTMorphingLabel {
    
    public typealias SKCountdownCompletion = () -> ()?
    public typealias SKCountdownExecution = () -> ()
    private let defaultFireIntervalSlow = 1.0
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
    
    public var timeCounted: NSTimeInterval {
        var timeCounted = NSDate().timeIntervalSinceDate(currentDate)
        
        if pausedDate != nil {
            let pausedCountedTime = NSDate().timeIntervalSinceDate(pausedDate)
            timeCounted -= pausedCountedTime
        }
        return round(timeCounted < 0 ? 0 : timeCounted)
    }
    
    public var timeRemaining: NSTimeInterval {
        return round(currentTimeInterval) - round(timeCounted)
    }
    
    public var timeDiff: NSTimeInterval {
        let diffTime = NSDate().timeIntervalSinceDate(currentDate)
        return diffTime
    }
    
    public var isEndOfTimer: Bool {
        return timeDiff >= currentTimeInterval
    }
    
    public var isPaused: Bool {
        return paused
    }
    
    public var isCounting: Bool {
        return counting
    }
    
    public var isFinished: Bool {
        return finished
    }
    
    public weak var countdownDelegate: SKCountdownLabelDelegate?
    
    // user settings
    public var animationType: SKAnimationEffect? {
        didSet {
            if let effect = animationType?.toLTMorphing() {
                morphingEffect = effect
                morphingEnabled = true
            } else {
                morphingEnabled = false
            }
        }
    }
    public var timeFormat = "HH:mm:ss"
    public var thens = [NSTimeInterval: SKCountdownExecution]()
    public var timerInText: SKTimerInText! {
        didSet {
            range = (timerInText.text as NSString).rangeOfString(timerInText.replacement)
        }
    }
    
    private var completion: SKCountdownCompletion?
    private var currentDate: NSDate = NSDate()
    private var currentTimeInterval: NSTimeInterval = 0
    private var currentDiffDate: NSDate!
    private var originTimeInterval: NSTimeInterval = 0
    private var pausedDate: NSDate!
    private var range: NSRange!
    private var timer: NSTimer!
    
    private var counting: Bool = false
    private var finished: Bool = false {
        didSet {
            if finished {
                paused = false
                counting = false
            }
        }
    }
    private var paused: Bool = false
    
    // MARK: - Initialize
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
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
        currentDate = origin
        currentTimeInterval = originTime
        currentDiffDate = date1970.dateByAddingTimeInterval(originTimeInterval)
        
        updateLabel()
    }
    
    public func setCountDownDate(origin: NSDate) {
        setCountDownDate(NSDate(), originDate: origin)
    }
    
    public func setCountDownDate(origin: NSDate, originDate: NSDate) {
        originTimeInterval = originDate.timeIntervalSinceDate(origin)
        currentDate = origin
        currentTimeInterval = originDate.timeIntervalSinceDate(origin)
        currentDiffDate = date1970.dateByAddingTimeInterval(originTimeInterval)
        
        updateLabel()
    }
    
    // MARK: - Update
    func updateLabel() {
        
        // delegate
        countdownDelegate?.countingAt?(timeCounted: timeCounted, timeRemaining: timeRemaining)
        
        // then function execute if needed
        thens.forEach { k, v in
            if k.int == timeRemaining.int {
                v()
                thens[k] = nil
            }
        }
        
        // update text
        updateText()
        
        // if end of timer
        if isEndOfTimer {
            text = dateFormatter.stringFromDate(date1970.dateByAddingTimeInterval(0))
            countdownDelegate?.countdownFinished?()
            dispose()
            completion?()
        }
    }
}

// MARK: - Public
public extension SKCountdownLabel {
    func start(completion: ( () -> () )? = nil) {
        // set completion if needed
        self.completion = completion
        
        // pause status check
        updatePauseStatusIfNeeded()
        
        // create timer
        updateTimer()
        
        // fire!
        timer.fire()
    }
    
    func pause() {
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
    
    func reset() {
        // reset if finished
        finished = false
        
        currentDate = NSDate()
        currentDiffDate = date1970.dateByAddingTimeInterval(originTimeInterval)
        currentTimeInterval = originTimeInterval
        
        updateLabel()
    }
   
    func addTimeCountedByTime(time: NSTimeInterval) {
        currentTimeInterval = time + currentTimeInterval
        currentDiffDate = date1970.dateByAddingTimeInterval(currentTimeInterval)
        
        updateLabel()
    }
    
    func then(targetTime: NSTimeInterval, completion: () -> ()) -> Self {
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
    func setup() {
        morphingEnabled = false
        
    }
    
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
        setNeedsDisplay()
    }
    
    func updatePauseStatusIfNeeded() {
        guard paused else {
            return
        }
        // change date
        let pastedTime = pausedDate.timeIntervalSinceDate(currentDate)
        currentDate = NSDate().dateByAddingTimeInterval(-pastedTime)
        
        // reset pause
        pausedDate = nil
        paused = false
    }
    
    func updateTimer() {
        // dispose
        disposeTimer()
        
        // create
        if timeFormat.rangeOfString("SS")?.underestimateCount() > 0 {
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalHighUse, target: self, selector: "updateLabel:", userInfo: nil, repeats: true)
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalSlow, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
        }
        
        // register to NSrunloop
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        counting = true
    }
    
    func disposeTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func dispose() {
        // reset
        pausedDate = nil
        
        // invalidate timer
        disposeTimer()
        
        // stop counting
        finished = true
    }
}

public enum SKAnimationEffect {
    case Scale
    case Evaporate
    case Fall
    case Pixelate
    case Sparkle
    case Burn
    case Anvil
    case None
    
    func toLTMorphing() -> LTMorphingEffect? {
        switch self {
        case .Scale     : return .Scale
        case .Evaporate : return .Evaporate
        case .Fall      : return .Fall
        case .Pixelate  : return .Pixelate
        case .Sparkle   : return .Sparkle
        case .Burn      : return .Burn
        case .Anvil     : return .Anvil
        case .None      : return nil
        }
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