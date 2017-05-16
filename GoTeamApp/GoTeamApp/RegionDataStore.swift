//
//  RegionDataStore.swift
//  GoTeamApp
//
//  Created by Wieniek Sliwinski on 5/14/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation
import Parse

class RegionDataStoreService : RegionDataStoreServiceProtocol {
  
  // user related
  let kUserName = "UserName"
  var userName = "akshay"
  
  func add(region : Region) {
    let parseTask = PFObject(className:Region.kRegionsClass)
    parseTask[User.kUserName] = userName
    parseTask[Region.kRegionID] = region.regionID
    parseTask[Region.kRegionName] = region.regionName
    parseTask[Region.kRegionLocationName] = region.regionLocationName
    parseTask[Region.kRegionRadius] = region.radius
    parseTask[Region.kRegionLatitude] = region.latitude
    parseTask[Region.kRegionLongitude] = region.longitude
    parseTask[Region.kRegionNotifyOnEntry] = region.notifyOnEntry
    parseTask[Region.kRegionNotifyOnExit] = region.notifyOnExit
    parseTask.saveInBackground { (success, error) in
      if success {
        print("saved successfully")
      } else {
        print(error)
      }
    }
  }
  
  func delete(region : Region) {
    let query = PFQuery(className:Region.kRegionsClass)
    query.whereKey(kUserName, equalTo: userName)
    query.whereKey(Region.kRegionID, equalTo: region.regionID)
    query.includeKey(Region.kRegionID)
    query.findObjectsInBackground(block: { (labels, error) in
      if let labels = labels {
        labels.first?.deleteEventually()
      }
    })
  }
  
  func allRegions(success:@escaping ([Region]) -> (), error: @escaping ((Error) -> ())) {
    let query = PFQuery(className:Region.kRegionsClass)
    query.whereKey(kUserName, equalTo: userName)
    query.includeKey(userName)
    query.findObjectsInBackground(block: { (regions, returnedError) in
      if let regions = regions {
        success(self.convertToRegions(pfRegions: regions))
      } else {
        if let returnedError = returnedError {
          error(returnedError)
        } else {
          error(NSError(domain: "failed to get regions, unknown error", code: 0, userInfo: nil))
        }
      }
    })
  }
  
  func convertToRegions(pfRegions : [PFObject]) -> [Region] {
    var regions = [Region]()
    for pfRegion in pfRegions {
      let region = Region()
      region.regionID = pfRegion[Region.kRegionID] as! Date
      region.regionName = pfRegion[Region.kRegionName] as? String
      region.regionLocationName = pfRegion[Region.kRegionLocationName] as? String
      region.radius = pfRegion[Region.kRegionRadius] as? Double
      region.latitude = pfRegion[Region.kRegionLatitude] as? Double
      region.longitude = pfRegion[Region.kRegionLongitude] as? Double
      region.notifyOnEntry = pfRegion[Region.kRegionNotifyOnEntry] as? Bool
      region.notifyOnExit = pfRegion[Region.kRegionNotifyOnExit] as? Bool
      regions.append(region)
    }
    return regions
  }
}
