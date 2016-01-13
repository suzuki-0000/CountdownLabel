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
    public static let replacementText = "[SKCountdownLabelReplacement]"
    private let defaultFireIntervalNormal = 0.1
    private let defaultFireIntervalHighUse = 0.01
    private let date1970 = NSDate(timeIntervalSince1970: 0)
    
    weak var delegate: SKCountdownLabelDelegate?
    
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
    
    // status: origin
    private var originCountDate: NSDate = NSDate()
    private var originTimeInterval: NSTimeInterval = 0
    // status: current
    private var currentCountDate: NSDate = NSDate()
    private var currentTimeInterval: NSTimeInterval = 0
    private var currentDiffDate: NSDate!
    // status: style
    public var attributes: [String: AnyObject]!
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
                v()
                thens[k] = nil
            }
        }
        
        if isEndOfTimer {
            if attributes != nil {
                let attrTextInRange = NSAttributedString(string: dateFormatter.stringFromDate(date1970.dateByAddingTimeInterval(0)), attributes: attributes)
                
                let attributedString = NSMutableAttributedString(string: text!)
                attributedString.replaceCharactersInRange((text! as NSString).rangeOfString(SKCountdownLabel.replacementText), withAttributedString: attrTextInRange)
                
                attributedText = attributedString
            } else {
                text = dateFormatter.stringFromDate(date1970.dateByAddingTimeInterval(0))
            }
        } else {
            text = dateFormatter.stringFromDate(currentDiffDate.dateByAddingTimeInterval(timeDiff * -1))
        }
        
        if isEndOfTimer {
            delegate?.countdownFinished()
            completion?()
            dispose()
        }
        
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
        
        thens[t] = completion
        return self
    }
}

// MARK: - private
private extension SKCountdownLabel {
    func setup(){
    }
}
//
//extension NSMutableParagraphStyle {
//    convenience init(lineSpacing: CGFloat, lineBreakMode: NSLineBreakMode? = nil, alignment: NSTextAlignment? = nil) {
//        self.init()
//        
//        self.lineSpacing = lineSpacing
//        if let lineBreakMode = lineBreakMode {
//            self.lineBreakMode = lineBreakMode
//        }
//        if let alignment = alignment {
//            self.alignment = alignment
//        }
//    }
//}

//extension NSMutableAttributedString {
//    convenience init(text: String, lineSpacing: CGFloat, lineBreakMode: NSLineBreakMode? = nil, alignment: NSTextAlignment? = nil, kerningWidth: CGFloat? = nil) {
//        self.init(string: text)
//        
//        let style = NSMutableParagraphStyle(lineSpacing: lineSpacing, lineBreakMode: lineBreakMode, alignment: alignment)
//        addAttribute(NSAttribute.ParagraphStyle(style))
//        if let kerningWidth = kerningWidth {
//            addAttribute(NSAttribute.Kern(kerningWidth))
//        }
//    }
//    
//    func appendString(string: String, attributes: NSAttributes) -> NSMutableAttributedString {
//        appendAttributedString(NSAttributedString(string: string, attributes: attributes))
//        return self
//    }
//    
//    func addAttribute(attribute: NSAttribute) -> NSMutableAttributedString {
//        return addAttribute(attribute, range: NSRange(location: 0, length: length))
//    }
//    
//    func addAttribute(attribute: NSAttribute, range: NSRange) -> NSMutableAttributedString {
//        addAttribute(attribute.name, value: attribute.value, range: range)
//        return self
//    }
//    
//    func addAttributes(attributes: NSAttributes) -> NSMutableAttributedString {
//        return addAttributes(attributes, range: NSRange(location: 0, length: length))
//    }
//    
//    func addAttributes(attributes: NSAttributes, range: NSRange) -> NSMutableAttributedString {
//        addAttributes(attributes.attributes, range: range)
//        return self
//    }
//}
//
//extension NSAttributedString {
//    convenience init(string: String, attributes: NSAttributes) {
//        self.init(string: string, attributes: attributes.attributes)
//    }
//}
//
////
//enum NSAttribute {
//    case Font(UIFont)
//    case IconFont(CGFloat)
//    case Color(UIColor)
//    case BaselineOffset(Float)
//    case ParagraphStyle(NSParagraphStyle)
//    case UnderlineStyle(NSUnderlineStyle)
//    case Kern(CGFloat)
//    case Link(NSURL)
//    
//    var name: String {
//        switch self {
//        case .Font: return NSFontAttributeName
//        case .IconFont: return NSFontAttributeName
//        case .Color: return NSForegroundColorAttributeName
//        case .BaselineOffset: return NSBaselineOffsetAttributeName
//        case .ParagraphStyle: return NSParagraphStyleAttributeName
//        case .UnderlineStyle: return NSUnderlineStyleAttributeName
//        case .Kern: return NSKernAttributeName
//        case .Link: return NSLinkAttributeName
//        }
//    }
//    
//    var value: AnyObject {
//        switch self {
//        case .Font(let font): return font
//        case .IconFont(let size): return UIFont.systemFontOfSize(size)
//        case .Color(let color): return color
//        case .BaselineOffset(let offset): return offset
//        case .ParagraphStyle(let style): return style
//        case .UnderlineStyle(let style): return style.rawValue
//        case .Kern(let kern): return kern
//        case .Link(let URL): return URL
//        }
//    }
//}
//
//class NSAttributes {
//    private var attrs: [String: NSAttribute] = [:]
//    
//    var attributes: [String: AnyObject] {
//        var result: [String: AnyObject] = [:]
//        
//        for (_, attr) in attrs {
//            result[attr.name] = attr.value
//        }
//        return result
//    }
//    
//    init() {
//    }
//    
//    init(_ attr: NSAttribute) {
//        set(attr)
//    }
//    
//    init(_ attrs: NSAttribute...) {
//        for attr in attrs {
//            set(attr)
//        }
//    }
//    
//    func set(attr: NSAttribute) -> Self {
//        attrs[attr.name] = attr
//        return self
//    }
//    
//    convenience init(font: UIFont) {
//        self.init(NSAttribute.Font(font))
//    }
//    
//    convenience init(font: UIFont, color: UIColor) {
//        self.init(.Font(font), .Color(color))
//    }
//    
//    convenience init(iconSize: CGFloat) {
//        self.init(NSAttribute.IconFont(iconSize))
//    }
//    
//    convenience init(iconSize: CGFloat, color: UIColor) {
//        self.init(.IconFont(iconSize), .Color(color))
//    }
//}
//
//
