//
//  Notifique.swift
//
//  Created by Christian Enevoldsen on 29/01/15.
//  Copyright (c) 2015 Reversebox. All rights reserved.
//

import UIKit

private var notifications: [Notifique] = []
private let helper = NotifiqueHelper()
private let nc = NSNotificationCenter.defaultCenter()

private class NotifiqueHelper: NSObject {
  
  override init() {
    super.init()
    nc.addObserver(
      self,
      selector: "exit:",
      name: UIApplicationWillTerminateNotification,
      object: nil
    )
  }
  
  func exit(notification: NSNotification) {
    
    for notification in notifications {
      nc.removeObserver(notification)
    }
    
    notifications.removeAll(keepCapacity: false)
    nc.removeObserver(self)
  }
  
}

public class Notifique: NSObject {
  
  public typealias NotifiqueHandler = ( notification: NSNotification,
    object: AnyObject? ) -> Void
  
  private var notificationName: String
  private var object: AnyObject?
  lazy private var closures: [NotifiqueHandler] = []
  
  init(notificationName _name: String) {
    notificationName = _name
  }
  
  public class func on(notificationName: String) -> Notifique {
    return Notifique(notificationName: notificationName)
  }
  
  public func with(object _object: AnyObject) -> Notifique? {
    //assert(object == nil, "\(__FUNCTION__) is not chainable. Make sure to call \(__FUNCTION__) only once")
    //assert(find(notifications, self) == nil, "\(__FUNCTION__) cannot be chained after selector \"then:\"")
    object = _object
    return self
  }
  
  public func then(closure: NotifiqueHandler) -> Notifique {
    self.closures.append(closure)
    if find(notifications, self) == nil {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "handle:", name: notificationName, object: object)
      notifications.append(self)
    }
    
    return self
  }
  
  public func then(target _target: AnyObject, selector: Selector) -> Notifique {
    NSNotificationCenter.defaultCenter().addObserver(_target, selector: selector, name: notificationName, object: object)
    
    if find(notifications, self) == nil {
      notifications.append(self)
    }
    return self
  }
  
  public func removeObserver(object: AnyObject) {
    NSNotificationCenter.defaultCenter().removeObserver(object)
  }
  
  func handle(notification: NSNotification) {
    for closure in closures {
      closure(notification: notification, object: object)
    }
  }
  
}
