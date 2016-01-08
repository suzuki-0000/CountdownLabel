//
//  SKCountdownLabelExampleTests.swift
//  SKCountdownLabelExampleTests
//
//  Created by 鈴木 啓司 on 2016/01/08.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
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

    func testCurrentTime() {
        let l = SKCountdownLabel()
        let origin = NSDate()
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
}
