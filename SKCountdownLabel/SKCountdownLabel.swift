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
    let defaultFireIntervalNormal = 1.0
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
        var timeCounted = NSDate().timeIntervalSinceDate(originCountDate)
        if pausedDate != nil {
            let pausedCountedTime = NSDate().timeIntervalSinceDate(pausedDate)
            timeCounted -= pausedCountedTime
        }
        return timeCounted
    }
    
    public var timeRemaining: NSTimeInterval {
        return originTimeInterval - timeCounted
    }
    
    public var timer: NSTimer!
    public var timeFormat = "HH:mm:ss"
    public var textRange: NSRange = NSRange()
    public var attributedDictionaryForTextInRange: NSDictionary!
    
    public var counting: Bool = false
    public var resetTimerAfterFinish: Bool = false
    public var shouldCountBeyondHHLimit: Bool = false
    
    // status: origin
    private var originCountDate: NSDate = NSDate()
    private var originTimeInterval: NSTimeInterval = 0
    private var diffDateFromOrigin: NSDate!
    // status: current
    private var currentTimeInterval: NSTimeInterval = 0
    // status: control
    private var pausedDate: NSDate!
    
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
        originTimeInterval = time > 0 ? time : 0
        diffDateFromOrigin = date1970.dateByAddingTimeInterval(originTimeInterval)
        
        updateLabel()
    }
    
    public func setCountDownDate(date: NSDate){
        let timeLeft = date.timeIntervalSinceDate(date)
        if timeLeft > 0 {
            originTimeInterval = timeLeft
            diffDateFromOrigin = date1970.dateByAddingTimeInterval(timeLeft)
        } else {
            originTimeInterval = 0
            diffDateFromOrigin = date1970.dateByAddingTimeInterval(0)
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
    
    func updateLabel() {
        debugPrint("updateLabel: ")
        let diffTime = NSDate().timeIntervalSinceDate(originCountDate)
        var showDate = NSDate()
        var timerEnded = false
        
        if counting {
            debugPrint("updateLabel: counting diffTime      \(diffTime)")
            debugPrint("updateLabel: counting originTimeInterval \(originTimeInterval)")
            
            let timeLeft = originTimeInterval - diffTime
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
            
            if diffTime >= originTimeInterval {
                debugPrint("updateLabel: will pause!!")
                pause()
                showDate = date1970.dateByAddingTimeInterval(0)
                debugPrint("updateLabel: no counting \(showDate)")
                timerEnded = true
            } else {
                showDate = diffDateFromOrigin.dateByAddingTimeInterval(diffTime * -1)
                debugPrint("updateLabel: no counting \(showDate)")
            }
        } else {
            debugPrint("updateLabel: no counting")
            showDate = diffDateFromOrigin
            debugPrint("updateLabel: no counting \(showDate)")
        }
        
        debugPrint("updateLabel: not shouldCountBeyondHHLimit")
        debugPrint("updateLabel: \(showDate)")
        
        if textRange.length > 0 {
            if attributedDictionaryForTextInRange != nil {
                
                let attrTextInRange = NSAttributedString(string: dateFormatter.stringFromDate(showDate), attributes: attributedDictionaryForTextInRange as? [String : AnyObject])
                
                let attributedString = NSMutableAttributedString(string: text!)
                attributedString.replaceCharactersInRange(textRange, withAttributedString: attrTextInRange)
                
                attributedText = attributedString
            } else {
                
                let labelText = (text! as NSString).stringByReplacingCharactersInRange(textRange, withString: dateFormatter.stringFromDate(showDate))
                
                text = labelText
            }
            
            
        } else  {
            text = dateFormatter.stringFromDate(showDate)
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
        
        if pausedDate != nil {
            let countedTime = pausedDate.timeIntervalSinceDate(originCountDate)
            originCountDate = NSDate().dateByAddingTimeInterval(-countedTime)
            pausedDate = nil
        }
        
        counting = true
        timer.fire()
    }
    
    func pause(){
        if !counting {
            return
        }
        
        timer.invalidate()
        timer = nil
        counting = false
        pausedDate = NSDate()
    }
    
    func reset(){
        pausedDate = nil
        originCountDate = NSDate()
        updateLabel()
    }
    
    func addTimeCountedByTime(timeToAdd: NSTimeInterval) {
        setCountDownTime(timeToAdd + originTimeInterval)
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
