//
//  CountdownLabel.swift
//  CountdownLabel
//
//  Created by suzuki keishi on 2016/01/06.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit
import LTMorphingLabel

@objc public protocol CountdownLabelDelegate {
    optional func countdownStarted()
    optional func countdownPaused()
    optional func countdownFinished()
    optional func countdownCancelled()
    optional func countingAt(timeCounted timeCounted: NSTimeInterval, timeRemaining: NSTimeInterval)
}

public extension NSTimeInterval {
    var int: Int {
        return Int(self)
    }
}

public class CountdownLabel: LTMorphingLabel {
    
    public typealias CountdownCompletion = () -> ()?
    public typealias CountdownExecution = () -> ()
    private let defaultFireInterval = 1.0
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
        let timeCounted = NSDate().timeIntervalSinceDate(fromDate)
        return round(timeCounted < 0 ? 0 : timeCounted)
    }
    
    public var timeRemaining: NSTimeInterval {
        return round(currentTime) - timeCounted
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
    
    public weak var countdownDelegate: CountdownLabelDelegate?
    
    // user settings
    public var animationType: CountdownEffect? {
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
    public var thens = [NSTimeInterval: CountdownExecution]()
    public var countdownAttributedText: CountdownAttributedText! {
        didSet {
            range = (countdownAttributedText.text as NSString).rangeOfString(countdownAttributedText.replacement)
        }
    }
    
    private var completion: CountdownCompletion?
    private var fromDate: NSDate = NSDate()
    private var currentDate: NSDate = NSDate()
    private var currentTime: NSTimeInterval = 0
    private var diffDate: NSDate!
    private var targetTime: NSTimeInterval = 0
    private var pausedDate: NSDate!
    private var range: NSRange!
    private var timer: NSTimer!
    
    private var counting: Bool = false
    private var endOfTimer: Bool {
        return timeCounted >= currentTime
    }
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
    
    public convenience init(frame: CGRect, minutes: NSTimeInterval) {
        self.init(frame: frame)
        setCountDownTime(minutes)
    }
    
    public convenience init(frame: CGRect, date: NSDate) {
        self.init(frame: frame)
        setCountDownDate(date)
    }
    
    public convenience init(frame: CGRect, fromDate: NSDate, targetDate: NSDate) {
        self.init(frame: frame)
        setCountDownDate(fromDate, targetDate: targetDate)
    }
    
    deinit {
        dispose()
    }
    
    // MARK: - Setter Methods
    public func setCountDownTime(minutes: NSTimeInterval) {
        setCountDownTime(NSDate(), minutes: minutes)
    }
    
    public func setCountDownTime(fromDate: NSDate, minutes: NSTimeInterval) {
        self.fromDate = fromDate
        
        targetTime = minutes
        currentTime = minutes
        diffDate = date1970.dateByAddingTimeInterval(minutes)
        
        updateLabel()
    }
    
    public func setCountDownDate(targetDate: NSDate) {
        setCountDownDate(NSDate(), targetDate: targetDate)
    }
    
    public func setCountDownDate(fromDate: NSDate, targetDate: NSDate) {
        self.fromDate = fromDate
        
        targetTime = targetDate.timeIntervalSinceDate(fromDate)
        currentTime = targetDate.timeIntervalSinceDate(fromDate) 
        diffDate = date1970.dateByAddingTimeInterval(targetTime)
        
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
        if endOfTimer {
            text = dateFormatter.stringFromDate(date1970.dateByAddingTimeInterval(0))
            countdownDelegate?.countdownFinished?()
            dispose()
            completion?()
        }
    }
}

// MARK: - Public
public extension CountdownLabel {
    func start(completion: ( () -> () )? = nil) {
        if !isPaused {
            // current date should be setted at the time of the counter's starting, or the time will be wrong (just a few seconds) after the first time of pausing.
            currentDate = NSDate()
        }
        
        // pause status check
        updatePauseStatusIfNeeded()
        
        // create timer
        updateTimer()
        
        // fire!
        timer.fire()
        
        // set completion if needed
        completion?()
        
        // set delegate
        countdownDelegate?.countdownStarted?()
    }
    
    func pause(completion: (() -> ())? = nil) {
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
        
        // set completion if needed
        completion?()
        
        // set delegate
        countdownDelegate?.countdownPaused?()
    }
    
    func cancel(completion: (() -> ())? = nil) {
        text = dateFormatter.stringFromDate(date1970.dateByAddingTimeInterval(0))
        dispose()
        
        // set completion if needed
        completion?()
        
        // set delegate
        countdownDelegate?.countdownCancelled?()
    }
    
    func addTime(time: NSTimeInterval) {
        currentTime = time + currentTime
        diffDate = date1970.dateByAddingTimeInterval(currentTime)
        
        updateLabel()
    }
    
    func then(targetTime: NSTimeInterval, completion: () -> ()) -> Self {
        let t = targetTime - (targetTime - targetTime)
        guard t > 0 else {
            return self
        }
        
        thens[t] = completion
        return self
    }
}

// MARK: - private
private extension CountdownLabel {
    func setup() {
        morphingEnabled = false
    }
    
    func updateText() {
        guard diffDate != nil else { return }

        // if time is before start
        let formattedText = timeCounted < 0
            ? dateFormatter.stringFromDate(date1970.dateByAddingTimeInterval(0))
            : dateFormatter.stringFromDate(diffDate.dateByAddingTimeInterval(round(timeCounted * -1)))
        
        if let countdownAttributedText = countdownAttributedText {
            let attrTextInRange = NSAttributedString(string: formattedText, attributes: countdownAttributedText.attributes)
            let attributedString = NSMutableAttributedString(string: countdownAttributedText.text)
            attributedString.replaceCharactersInRange(range, withAttributedString: attrTextInRange)
            
            attributedText = attributedString
            text = attributedString.string
        } else {
            text = formattedText
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
        fromDate = currentDate
        
        // reset pause
        pausedDate = nil
        paused = false
    }
    
    func updateTimer() {
        disposeTimer()
        
        // create
        timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireInterval,
                                                       target: self,
                                                       selector: #selector(updateLabel),
                                                       userInfo: nil,
                                                       repeats: true)
        
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

public enum CountdownEffect {
    case Anvil
    case Burn
    case Evaporate
    case Fall
    case None
    case Pixelate
    case Scale
    case Sparkle
    
    func toLTMorphing() -> LTMorphingEffect? {
        switch self {
        case .Anvil     : return .Anvil
        case .Burn      : return .Burn
        case .Evaporate : return .Evaporate
        case .Fall      : return .Fall
        case .None      : return nil
        case .Pixelate  : return .Pixelate
        case .Scale     : return .Scale
        case .Sparkle   : return .Sparkle
        }
    }
}

public class CountdownAttributedText: NSObject {
    private let text: String
    private let replacement: String
    private let attributes: [String: AnyObject]?
   
    public init(text: String, replacement: String, attributes: [String: AnyObject]? = nil) {
        self.text = text
        self.replacement = replacement
        self.attributes = attributes
    }
}