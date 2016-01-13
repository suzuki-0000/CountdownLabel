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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithCoder() {
        let storyboard = UIStoryboard(name: "StoryboardTests", bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateInitialViewController()
        XCTAssertNotNil(vc)
        XCTAssertEqual(vc?.view.subviews.count, 3)
    }
    
    func testInitWithFrame() {
        let l = SKCountdownLabel()
        XCTAssertNotNil(l)
    }

    func testStartStatus() {
        let label = SKCountdownLabel()
        
        label.setCountDownTime(30)
        label.start()
        
        XCTAssertEqual(label.counting, true)
        XCTAssertEqual(label.paused, false)
        XCTAssertEqual(label.timeFormat, "HH:mm:ss")
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
        
        let expectation = expectationWithDescription("refreshed")
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
        
        let expectation = expectationWithDescription("refreshed")
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
        
        let expectation = expectationWithDescription("refreshed")
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
        
        let expectation = expectationWithDescription("refreshed")
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
        
        let expectation = expectationWithDescription("refreshed")
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
        
        let expectation = expectationWithDescription("refreshed")
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
        
        let expectation = expectationWithDescription("refreshed")
        delay(2.1){
            XCTAssertEqual(completionChangedValue, 4)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func dateFrom(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> NSDate {
        let string = String(format: "%d-%02d-%dT%d:%02d:28+0900", year, month, day, hour, minute)
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.dateFromString(string)!
    }
    
    func testAttributedText(){
        let label = SKCountdownLabel()
        label.setCountDownTime(10)
        label.text = "hello \(SKCountdownLabel.replacementText)"
        label.attributes = [NSForegroundColorAttributeName: UIColor.redColor()]
        label.start()
        
        debugPrint("===-----------")
        debugPrint("===-----------")
        debugPrint(label.attributedText!.string)
        XCTAssert(label.attributedText!.string.containsString("hello"))
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func rangeCheck(string: String)(_ from: Int, _ len: Int) -> Range<String.Index> {
        let start = string.startIndex.advancedBy(from)
        let end = start.advancedBy(len)
        return Range(start: start, end: end)
    }
}
