//
//  SKCountdownLabelExampleTests.swift
//  SKCountdownLabelExampleTests
//
//  Created by suzuki keishi on 2016/01/08.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import XCTest
import SKCountdownLabel
@testable import SKCountdownLabelExample

class SKCountdownLabelExampleTests: XCTestCase {
    
    func testInitWithCoder() {
        let storyboard = UIStoryboard(name: "StoryboardTests", bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateInitialViewController()
        XCTAssertNotNil(vc)
        XCTAssertEqual(vc?.view.subviews.count, 3)
    }
    
    func testInitWithFrame() {
        let label = SKCountdownLabel()
        
        XCTAssertNotNil(label)
    }

    func testStartStatus() {
        let label = SKCountdownLabel(frame: CGRectZero, time: 30)
        label.start()
        
        XCTAssertEqual(label.counting, true)
        XCTAssertEqual(label.paused, false)
        XCTAssertEqual(label.timeFormat, "HH:mm:ss")
    }
    
    func testSettingCountdownTime() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        label.pause()
        
        XCTAssertEqual(label.counting, false)
        XCTAssertEqual(label.paused, true)
        XCTAssertEqual(label.finished, false)
        XCTAssertEqual(label.timeCounted.int, 0)
        XCTAssertEqual(label.timeRemaining.int, 30)
    }
    
    func testSettingCountdownDate() {
        let label = SKCountdownLabel()
        let targetDate = NSDate().dateByAddingTimeInterval(30)
        
        label.setCountDownDate(targetDate)
        label.start()
        label.pause()
        
        XCTAssertEqual(label.counting, false)
        XCTAssertEqual(label.paused, true)
        XCTAssertEqual(label.finished, false)
        XCTAssertEqual(label.timeCounted.int, 0)
        XCTAssertEqual(label.timeRemaining.int, 30)
    }
    
    func testPauseStatus() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        label.pause()
        
        XCTAssertEqual(label.counting, false)
        XCTAssertEqual(label.paused, true)
        XCTAssertEqual(label.finished, false)
        XCTAssertEqual(label.timeCounted.int, 0)
        XCTAssertEqual(label.timeRemaining.int, 30)
    }
    
    func testAfterASecond() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        
        let expectation = expectationWithDescription("expect")
        delay(1.0){
            label.pause()
            
            XCTAssertEqual(label.counting, false)
            XCTAssertEqual(label.paused, true)
            XCTAssertEqual(label.finished, false)
            XCTAssertEqual(label.timeCounted.int, 1)
            XCTAssertEqual(label.timeRemaining.int, 29)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testAfterASecondDate() {
        let label = SKCountdownLabel()
        
        let targetDate = NSDate().dateByAddingTimeInterval(30)
        label.setCountDownDate(targetDate)
        label.start()
        
        let expectation = expectationWithDescription("expect")
        delay(1.0){
            label.pause()
            
            XCTAssertEqual(label.counting, false)
            XCTAssertEqual(label.paused, true)
            XCTAssertEqual(label.finished, false)
            XCTAssertEqual(label.timeCounted.int, 1)
            XCTAssertEqual(label.timeRemaining.int, 29)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testReset() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        
        let expectation = expectationWithDescription("expect")
        delay(1.0){
            label.pause()
            label.reset()
            
            XCTAssertEqual(label.counting, false)
            XCTAssertEqual(label.paused, true)
            XCTAssertEqual(label.finished, false)
            XCTAssertEqual(label.timeCounted.int, 0)
            XCTAssertEqual(label.timeRemaining.int, 30)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testRestart() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        
        let expectation = expectationWithDescription("expect")
        delay(1.0){
            label.pause()
            label.start()
            
            XCTAssertEqual(label.counting, true)
            XCTAssertEqual(label.paused, false)
            XCTAssertEqual(label.finished, false)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testAddTime() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        label.pause()
        label.addTimeCountedByTime(1)
        
        XCTAssertEqual(label.timeCounted.int, 0)
        XCTAssertEqual(label.timeRemaining.int, 31)
    }
    
    func testMinusTime() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        label.pause()
        label.addTimeCountedByTime(-1)
        
        XCTAssertEqual(label.timeCounted.int, 0)
        XCTAssertEqual(label.timeRemaining.int, 29)
    }
    
    func testResetAfterControl() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        label.addTimeCountedByTime(+10)
        
        let expectation = expectationWithDescription("expect")
        delay(1.0){
            label.pause()
            label.reset()
            
            XCTAssertEqual(label.counting, false)
            XCTAssertEqual(label.paused, true)
            XCTAssertEqual(label.finished, false)
            XCTAssertEqual(label.timeCounted.int, 0)
            XCTAssertEqual(label.timeRemaining.int, 30)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testCountdownFinished() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(1)
        label.start()
        
        let expectation = expectationWithDescription("expect")
        delay(1.1){
            
            XCTAssertEqual(label.finished, true)
            XCTAssertEqual(label.counting, false)
            XCTAssertEqual(label.paused, false)
            XCTAssertEqual(label.timeCounted.int, 1)
            XCTAssertEqual(label.timeRemaining.int, 0)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testCountdownFinishedWithCompletion() {
        let label = SKCountdownLabel()
        
        var completionChangedValue = 1
        label.setCountDownTime(1)
        label.start() {
            completionChangedValue = 2
        }
        
        let expectation = expectationWithDescription("expect")
        delay(1.1){
            
            XCTAssertEqual(completionChangedValue, 2)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testCountdownThen() {
        let label = SKCountdownLabel()
        
        var completionChangedValue = 1
        label.setCountDownTime(10)
        label.then(9){
            completionChangedValue++
        }
        label.then(8){
            completionChangedValue++
            completionChangedValue++
        }
        label.start()
        
        let expectation = expectationWithDescription("expect")
        delay(2.1){
            XCTAssertEqual(completionChangedValue, 4)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }

    func testAttributedText(){
        let label = SKCountdownLabel()
        label.setCountDownTime(10)
        label.timerInText = SKTimerInText(text: "hello timer in text",
            replacement: "timer",
            attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
        label.start()
        
        XCTAssert( label.attributedText!.string.containsString("hello"))
        XCTAssert(!label.attributedText!.string.containsString("timer"))
        XCTAssert( label.attributedText!.string.containsString("in"))
        XCTAssert( label.attributedText!.string.containsString("text"))
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
