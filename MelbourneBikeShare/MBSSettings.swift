//
//  MBSSettings.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 6/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import Foundation
import GoogleMaps

class MBSSettings {
    
    struct Key {
        static let DEFAULT_CAMERA_POSITION = "DefaultCameraPosition"
        static let GOOGLE_API_KEY = "GoogleMapsAPIKey"
        static let BIKE_SHARE_URL = "BikeShareUrl"
    }
    
    static let sharedInstance = MBSSettings()

    struct Constants {
        static let FILE_NAME = "Settings"
        static let FILE_TYPE = "plist"
    }
    
    private let _dict: NSDictionary?
    
    init() {
        let filePath = NSBundle.mainBundle().pathForResource(Constants.FILE_NAME,
                                                      ofType:Constants.FILE_TYPE)
        if filePath != nil {
            _dict = NSDictionary(contentsOfFile: filePath!)
        } else {
            _dict = nil
        }
    }
    
    func objectForKey(key: String) -> AnyObject? {
        if _dict != nil {
            return _dict!.valueForKey(key)
        }
        return nil
    }
    
    func stringForKey(key: String) -> String? {
        let obj = objectForKey(key)
        if obj != nil {
            return "\(obj!)"
        }
        return nil
    }
    
    func dictionaryForKey(key: String) -> NSDictionary? {
        let obj = objectForKey(key)
        if obj != nil && obj!.isKindOfClass(NSDictionary){
            return (obj! as! NSDictionary)
        }
        return nil
    }
}

// MARK: - MBSSettings Extensions

extension MBSSettings {
    func defaultCameraPosition() -> GMSCameraPosition? {
        
        let cameraDict = self.dictionaryForKey(Key.DEFAULT_CAMERA_POSITION)
        if cameraDict == nil {
            return nil
        }
        
        let dictLatitude = cameraDict!["latitude"]
        if dictLatitude == nil || !dictLatitude!.isKindOfClass(NSNumber) {
            return nil;
        }
        
        let dictLongitude = cameraDict!["longitude"]
        if dictLongitude == nil || !dictLongitude!.isKindOfClass(NSNumber) {
            return nil;
        }
        
        let dictZoom = cameraDict!["zoom"]
        if dictZoom == nil || !dictZoom!.isKindOfClass(NSNumber) {
            return nil;
        }
        
        let latitude = (dictLatitude! as! NSNumber).doubleValue
        let longitude = (dictLongitude! as! NSNumber).doubleValue
        let zoom = (dictZoom! as! NSNumber).floatValue
        
        return GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: zoom)
    }
}
