//
//  NotifiqueTests.swift
//  NotifiqueTests
//
//  Created by Christian Enevoldsen on 29/01/15.
//  Copyright (c) 2015 Reversebox. All rights reserved.
//

import UIKit
import XCTest
import Notifique

class NotifiqueTests: XCTestCase {
  
  var count:Int = 0
  var update: Int = 1
  var update2: Int = 0
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func update(n: NSNotification) {
    self.update = 1337
  }
  
  func update2(n: NSNotification) {
    self.update2 = 2
  }
  
  func update3(n: NSNotification) {
    self.update = 89
  }
  
  func testThen() {
    Notifique.on("test")
      .then { (notification, object) in self.count = 1 }
      .then { (notification, object) in self.count = 2 }
    NSNotificationCenter.defaultCenter().postNotificationName("test", object: nil)
    XCTAssert(count == 2, "Failed")
  }
  
  func testWith() {
    var withObject = "with"
    Notifique.on("test").with(object: withObject)?
      .then { (notification, object) in
        XCTAssertEqual(withObject, object as String, "should be equal object from arguments")
      }
    NSNotificationCenter.defaultCenter().postNotificationName("test", object: nil)
  }
  
  func testThenTarget() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      NSNotificationCenter.defaultCenter().postNotificationName("target", object: self)
      XCTAssert(self.update == 1337, "should be 1337")
    })
  }
  
  func testThenThen() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      NSNotificationCenter.defaultCenter().postNotificationName("target2", object: self)
      XCTAssert(self.update == self.update2, "should be 0")
    })
  }
  
  func testThenThenTarget() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      NSNotificationCenter.defaultCenter().postNotificationName("target3", object: self)
      XCTAssert(self.update == 89, "should be 89")
    })
  }
  
}
