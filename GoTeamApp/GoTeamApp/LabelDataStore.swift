//
//  LabelDataStore.swift
//  GoTeamApp
//
//  Created by Akshay Bhandary on 5/5/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation

import Foundation
import Parse

class LabelDataStoreService : LabelDataStoreServiceProtocol {
    
    
    // user related
    let kTUserName = "UserName"
    
    
    // label related
    let kLabelsClass = "LabelsClassV2"
    let kLabelID   = "labelID"
    let kLabelName = "labelName"
    var userName = "akshay"
    

    func add(label : Labels) {
        
        let parseTask = PFObject(className:kLabelsClass)
        parseTask[kTUserName] = userName
        parseTask[kLabelName] = label.labelName
        parseTask[kLabelID] = label.labelID
        parseTask.saveInBackground { (success, error) in
            if success {
                print("saved successfully")
            } else {
                print(error)
            }
        }
    }
    
    
    func delete(label : Labels) {
        let query = PFQuery(className:kLabelsClass)
        query.whereKey(kTUserName, equalTo: userName)
        query.whereKey(kLabelID, equalTo: label.labelID!)
        query.includeKey(kLabelID)
        query.findObjectsInBackground(block: { (labels, error) in
            if let labels = labels {
                labels.first?.deleteEventually()
            }
        })
    }
    
    
    func allLabels(success:@escaping ([Labels]) -> (), error: @escaping ((Error) -> ())) {
        let query = PFQuery(className:kLabelsClass)
        query.whereKey(kTUserName, equalTo: userName)
        query.includeKey(userName)
        query.findObjectsInBackground(block: { (labels, returnedError) in
            if let labels = labels {
                success(self.convertToLabels(pfLabels: labels))
            } else {
                if let returnedError = returnedError {
                    error(returnedError)
                } else {
                    error(NSError(domain: "failed to get labels, unknown error", code: 0, userInfo: nil))
                }
            }
        })
    }
    
 
    
    func convertToLabels(pfLabels : [PFObject]) -> [Labels] {
        var labels = [Labels]()
        for pfLabel in pfLabels {
            let label = Labels()
            label.labelID = pfLabel[kLabelID] as? Date
            label.labelName = pfLabel[kLabelName] as? String
            labels.append(label)
        }
        return labels
    }
}