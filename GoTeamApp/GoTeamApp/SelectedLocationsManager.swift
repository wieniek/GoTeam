//
//  SelectedLocationsManager.swift
//  GoTeamApp
//
//  Created by Wieniek Sliwinski on 5/5/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation

class SelectedLocationsManager {
  
  var locations = [Location]()
  let dataStoreService : LocationDataStoreServiceProtocol = LocationDataStoreService()
  
  let queue = DispatchQueue(label: "SelectedLocationsManagerQueue")
  
  static let sharedInstance = SelectedLocationsManager()
    
  func add(location : Location) {
    queue.async {
      self.locations.append(location)
      self.dataStoreService.add(location: location)
    }
  }
  
  func delete(location: Location) {
    queue.async {
      self.locations = self.locations.filter() { $0 !== location }
      self.dataStoreService.delete(location: location)
    }
  }
  
  func update(location: Location) {
    queue.async {
      self.dataStoreService.update(location: location)
    }
  }
  
  func allLocations(fetch: Bool, success:@escaping (([Location]) -> ()), error: @escaping (Error) -> ()) {
    queue.async {
      if fetch == false {
        success(self.locations)
      } else {
        self.dataStoreService.allLocations(success: { (locations) in
            self.locations = locations
            success(locations)
            }, error: error)
      }
    }
  }
}
