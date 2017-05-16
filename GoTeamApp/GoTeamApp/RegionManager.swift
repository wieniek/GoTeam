//
//  RegionManager.swift
//  GoTeamApp
//
//  Created by Wieniek Sliwinski on 5/14/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import CoreLocation

class RegionManager : NSObject {
  
  static let sharedInstance = RegionManager()
  static let regionRadiuses = ["10","30","100"]
  static let boundaryCrossings = ["Notify on Entry", "Notify on Exit", "Notify on Entry & Exit"]
  
  let locationManager = CLLocationManager()
  
  var regions = [Region]()
  let dataStoreService : RegionDataStoreServiceProtocol = RegionDataStoreService()
  
  let queue = DispatchQueue(label: Resources.Strings.RegionManager.kRegionManagerQueue)
  
  func add(region : Region) {
    queue.async {
      self.regions.append(region)
      self.dataStoreService.add(region: region)
    }
  }
  
  func delete(region : Region) {
    queue.async {
      self.regions = self.regions.filter() { $0 !== region }
      self.dataStoreService.delete(region: region)
    }
  }
  
  func startMonitoring(region : Region) {
      let circularRegion = CLCircularRegion(center: region.coordinate, radius: region.radius!, identifier: region.regionName!)
      circularRegion.notifyOnEntry = region.notifyOnEntry!
      circularRegion.notifyOnExit = region.notifyOnExit!
      locationManager.startMonitoring(for: circularRegion)
  }
  
    func allRegions(fetch: Bool, success:@escaping (([Region]) -> ()), error: @escaping (Error) -> ()) {
      queue.async {
        if fetch == false {
          success(self.regions)
        } else {
          self.dataStoreService.allRegions(success: { (regions) in
            self.regions = regions
            success(regions)
          }, error: error)
        }
      }
    }
  
  func showNotification(withMessage message: String) {
    let notification = UNMutableNotificationContent()
    notification.title = "GoTeam App"
    notification.subtitle = "Monitoring status"
    notification.body = message
    notification.sound = .default()
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound], completionHandler: { (returnedBool, error) in
      if returnedBool == true && error == nil {
        let content = UNMutableNotificationContent()
        content.title = "GoTeam App"
        content.subtitle = "Monitoring status"
        content.body = message
        content.sound = .default()
        UNUserNotificationCenter.current().delegate = self
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: message, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
              // @todo: show an error dialog
          }
        }
      }
    })
  }
}

extension RegionManager : UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    // print("Tapped in notification")
  }
  
  //This is key callback to present notification while the app is in foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
    //to distinguish between notifications
    completionHandler( [.alert,.sound,.badge])
  }
}
