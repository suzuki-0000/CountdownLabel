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


public class SKCountdownLabel: UILabel{
    
    public typealias CountdownCompletion = () -> ()?
    public typealias Execution = () -> ()
    
    let defaultTimeFormat = "HH:mm:ss"
    let hourFormatReplace = "!!!*"
    let defaultFireIntervalNormal = 1.0
    let defaultFireIntervalHighUse = 0.01
    
    weak var delegate: SKCountdownLabelDelegate?
    
    public lazy var dateFormatter: NSDateFormatter = { [unowned self] in
        let df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "ja_JP")
        df.timeZone = NSTimeZone(name: "GMT")
        df.dateFormat = self.timeFormat
        return df
    }()
    
    public var timeCounted:NSTimeInterval {
        if startCountDate == nil {
            return 0
        }
        
        var timeCounted = NSDate().timeIntervalSinceDate(startCountDate)
        if pausedTime != nil {
            let pausedCountedTime = NSDate().timeIntervalSinceDate(pausedTime)
            timeCounted -= pausedCountedTime
        }
        
        return timeCounted
    }
    
    public var timeRemaining: NSTimeInterval {
        return timeUserValue - timeCounted
    }
    
    public var timer: NSTimer!
    public var timeFormat: String!
    public var textRange: NSRange = NSRange()
    public var attributedDictionaryForTextInRange: NSDictionary!
    
    public var counting: Bool = false
    public var resetTimerAfterFinish: Bool = false
    public var shouldCountBeyondHHLimit: Bool = false
    public var thens = [NSTimeInterval: Execution]()
    public var lessThans = [NSTimeInterval: Execution]()
    public var moreThans = [NSTimeInterval: Execution]()
    
    private var timeUserValue: NSTimeInterval = 0
    private var startCountDate: NSDate!
    private var pausedTime: NSDate!
    private var date1970: NSDate!
    private var timeToCountOff: NSDate!
    private var completion: CountdownCompletion?
    
    // MARK: - Initialize
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(label: UILabel) {
        self.init(frame: CGRectZero)
        setup()
    }
    
    convenience init(frame: CGRect, label: UILabel) {
        self.init(frame: frame)
        setup()
    }
    
    // MARK: - Setter Methods
    public func setCountDownTime(time: NSTimeInterval) {
        timeUserValue = time < 0 ? 0 : time
        timeToCountOff = date1970.dateByAddingTimeInterval(timeUserValue)
        
        updateLabel()
    }
    
    func setCountDownToDate(date: NSDate){
        let timeLeft = date.timeIntervalSinceDate(date)
        if timeLeft > 0 {
            timeUserValue = timeLeft
            timeToCountOff = date1970.dateByAddingTimeInterval(timeLeft)
        } else {
            timeUserValue = 0
            timeToCountOff = date1970.dateByAddingTimeInterval(0)
        }
        
        updateLabel()
    }
    
    // MARK: - Update Methods
    func updateTimeFormat(timeFormat: String){
        if !timeFormat.isEmpty {
            self.timeFormat = timeFormat
        }
        
        updateLabel()
    }
    
    func updateShouldCountBeyondHHLimit(shouldCountBeyondHHLimit:Bool){
        self.shouldCountBeyondHHLimit = shouldCountBeyondHHLimit
        updateLabel()
    }
    
    // MARK: - Getter Methods
    func findTimeFormat() -> String {
        if timeFormat.isEmpty {
            return defaultTimeFormat
        }
        
        return timeFormat
    }

    
    func updateLabel() {
        debugPrint("updateLabel: ")
        let timeDiff = NSDate().timeIntervalSinceDate(startCountDate)
        var timeToShow = NSDate()
        var timerEnded = false
        
        if counting {
            debugPrint("updateLabel: counting timeDiff      \(timeDiff)")
            debugPrint("updateLabel: counting timeUserValue \(timeUserValue)")
            
            let timeLeft = timeUserValue - timeDiff
            delegate?.countingTo(timeLeft)
            
            debugPrint("updateLabel: counting timeLeft      \(timeLeft)")
           
            thens.forEach { k,v in
               debugPrint(Int(k))
               debugPrint(Int(timeLeft))
                if Int(k) == Int(timeLeft) {
                    debugPrint("inside !!!!")
                    v()
                }
            }
            
            
            
            if timeDiff >= timeUserValue {
                debugPrint("updateLabel: will pause!!")
                pause()
                timeToShow = date1970.dateByAddingTimeInterval(0)
                startCountDate = nil
                timerEnded = true
            } else {
                timeToShow = timeToCountOff.dateByAddingTimeInterval(timeDiff * -1)
            }
        } else {
            debugPrint("updateLabel: no counting")
            timeToShow = timeToCountOff
        }
        
        if shouldCountBeyondHHLimit {
            debugPrint("updateLabel: shouldCountBeyondHHLimit")
            
            let originalTimeFormat = timeFormat
            var beyondFormat = timeFormat.stringByReplacingOccurrencesOfString("HH", withString: hourFormatReplace)
            beyondFormat = beyondFormat.stringByReplacingOccurrencesOfString("H", withString: hourFormatReplace)
            
            dateFormatter.dateFormat = beyondFormat
            
            let hours = timeRemaining / 3600
            let formattedDate = dateFormatter.stringFromDate(timeToShow)
            let beyondedDate = formattedDate.stringByReplacingOccurrencesOfString(hourFormatReplace, withString: NSString(format: "%02d", hours) as String)
            
            text = beyondedDate
            dateFormatter.dateFormat = originalTimeFormat
            
        } else {
            debugPrint("updateLabel: not shouldCountBeyondHHLimit")
            debugPrint("updateLabel: \(timeToShow)")
            
            if textRange.length > 0 {
                if attributedDictionaryForTextInRange != nil {
                    
                    let attrTextInRange = NSAttributedString(string: dateFormatter.stringFromDate(timeToShow), attributes: attributedDictionaryForTextInRange as? [String : AnyObject])
                    
                    let attributedString = NSMutableAttributedString(string: text!)
                    attributedString.replaceCharactersInRange(textRange, withAttributedString: attrTextInRange)
                    
                    attributedText = attributedString
                } else {
                    
                    let labelText = (text! as NSString).stringByReplacingCharactersInRange(textRange, withString: dateFormatter.stringFromDate(timeToShow))
                    
                    text = labelText
                }
                
                
            } else  {
                text = dateFormatter.stringFromDate(timeToShow)
            }
        }
        
        
        if timerEnded {
            delegate?.countdownFinished()
            completion?()
            if resetTimerAfterFinish {
                reset()
            }
        }
    }
}


// MARK: - Public
public extension SKCountdownLabel {
    func start(completion: CountdownCompletion? = nil){
        debugPrint("start:")
        
        self.completion = completion
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        if timeFormat.rangeOfString("SS")?.underestimateCount() > 0 {
            debugPrint("start: SS")
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalHighUse, target: self, selector: "updateLabel:", userInfo: nil, repeats: true)
        } else {
            debugPrint("start: SS not")
            timer = NSTimer.scheduledTimerWithTimeInterval(defaultFireIntervalNormal, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
        }
        
        //TODO : what
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        if startCountDate == nil {
            startCountDate = NSDate()
            
            if timeUserValue > 0 {
                startCountDate = startCountDate.dateByAddingTimeInterval(-timeUserValue)
            }
        }
        
        if pausedTime != nil {
            let countedTime = pausedTime.timeIntervalSinceDate(startCountDate)
            startCountDate = NSDate().dateByAddingTimeInterval(-countedTime)
            pausedTime = nil
        }
        
        counting = true
        timer.fire()
    }
    
    func pause(){
        if counting {
            timer.invalidate()
            timer = nil
            counting = false
            pausedTime = NSDate()
        }
    }
    
    func reset(){
        pausedTime = nil
        startCountDate = NSDate()
        updateLabel()
    }
    
    func addTimeCountedByTime(timeToAdd: NSTimeInterval) {
        setCountDownTime(timeToAdd + timeUserValue)
        updateLabel()
    }
    
    func then(targetTime: NSTimeInterval, completion: () -> ()) -> Self{
        let t = timeUserValue - (timeUserValue - targetTime)
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
        date1970 = NSDate(timeIntervalSince1970: 0)
        timeFormat = defaultTimeFormat
        startCountDate = NSDate()
    }
}


//static func countDownTimer(origin: NSDate)(_ startAt: NSDate?) -> String {
//    guard let startAt = startAt else {
//        return ""
//    }
//
//    let diff = startAt.timeIntervalSinceDate(origin)
//    let diffDate = NSDate(timeIntervalSince1970: 0).dateByAddingTimeInterval(diff)
//    let formatter = NSDateFormatter()
//    formatter.locale = NSLocale(localeIdentifier: "ja_JP")
//    formatter.dateFormat = countdownFormat
//    formatter.timeZone = NSTimeZone(name: "GMT")
//    return formatter.stringFromDate(diffDate)
//}

//static func withinADay(origin: NSDate)(_ diffDate: NSDate?) -> Bool {
//    guard let diffDate = diffDate else {
//        return false
//    }
//    let diff = diffDate.timeIntervalSinceDate(origin)
//    return 0 <= diff && diff < 60*60*24
//}//

//static func hourMinuteSecond(seconds: Int) -> String {
//    if seconds < 0 {
//        return L10n.UndefinedTime.string
//    }
//
//    let minutes = seconds / 60
//
//    let s = seconds % 60
//    let m = minutes % 60
//    let h = minutes / 60
//
//    let hString = h > 0 ? "\(h):" : ""
//    let mString = h > 0 ? String(format: "%02d:", m) : String(format: "%d:", m)
//    let sString = String(format: "%02d", s)
//
//    return hString + mString + sString
//}


//
//static func stringFromDate(dateFormat: String)(_ date: NSDate) -> String {
//    let formatter = NSDateFormatter()
//    formatter.locale = NSLocale(localeIdentifier: "ja_JP")
//    formatter.dateFormat = dateFormat
//    return formatter.stringFromDate(date)
//}
