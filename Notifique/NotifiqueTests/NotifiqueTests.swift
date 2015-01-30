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
    Notifique.on("target3").then(target: self, selector: "update:").then(target: self, selector: "update2:").then(target: self, selector: "update3:")
    Notifique.on("target").then(target: self, selector: "update:")
    Notifique.on("target2").then(target: self, selector: "update2:").then { (notificaition, object) -> Void in
      self.update = 2
    }
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
    Notifique.on("test").then { (notificaition, object) -> Void in
      self.count = 1
      }.then { (notificaition, object) -> Void in
        self.count = 2
    }
    NSNotificationCenter.defaultCenter().postNotificationName("test", object: nil)
    XCTAssert(count == 2, "Failed")
  }
  
  func testWith() {
    var s = "with"
    Notifique.on("test").with(object: s).then { (notificaition, object) -> Void in
      XCTAssertEqual(s, (object as String), "")
    }
    NSNotificationCenter.defaultCenter().postNotificationName("test", object: nil)
  }
  
  
  func testThenTarget() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      NSNotificationCenter.defaultCenter().postNotificationName("target", object: self)
      XCTAssert(self.update == 1337, "expected 1337 but got \(self.update)")
    })
  }
  
  func testThenThen() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      NSNotificationCenter.defaultCenter().postNotificationName("target2", object: self)
      XCTAssert(self.update == self.update2, "expected \(self.update) = \(self.update2)")
    })
  }
  
  func testThenThenTarget() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      NSNotificationCenter.defaultCenter().postNotificationName("target3", object: self)
      XCTAssert(self.update == 89, "expected \(self.update) = 89")
    })
  }
  
}
