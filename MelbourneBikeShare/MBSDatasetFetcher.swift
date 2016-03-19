//
//  MBSDatasetFetcher.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 4/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import UIKit
import MapKit

protocol MBSDatasetFetcherDelegate : NSObjectProtocol {
    func datasetFetcher(datasetFetcher: MBSDatasetFetcher, didFetchBikeStations bikeStations: Array<MBSBikeStation>)
    func datasetFetcher(datasetFetcher: MBSDatasetFetcher, didFailWithMessage message: String)
}

class MBSDatasetFetcher: NSObject, NSURLConnectionDataDelegate {
    weak var delegate: MBSDatasetFetcherDelegate?
    
    private let _bikeShareUrl: String
    private let _urlSession: NSURLSession
    private var _urlSessionDataTask: NSURLSessionDataTask?
    
    override init() {
        let settings = MBSSettings.sharedInstance
        let serviceUrl = settings.stringForKey(MBSSettings.Key.BIKE_SHARE_URL)
        
        if serviceUrl != nil {
            _bikeShareUrl = serviceUrl!
        } else {
            // fallback to hardcoded URL
            _bikeShareUrl = "https://data.melbourne.vic.gov.au/api/views/tdvh-n9dv/rows.json?accessType=DOWNLOAD"
        }

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        _urlSession = NSURLSession(configuration: configuration)

        super.init()
    }
    
    func fetchBikeStations() -> Bool {
   
        if _urlSessionDataTask != nil {
            // previous session is going on
            return false
        }
        
        let url = NSURL(string: _bikeShareUrl)
        
        let task = _urlSession.dataTaskWithURL(url!) { (data, response, error) in
            
            self._urlSessionDataTask = nil
            
            if error == nil {
                let bikeStations = self.parseBikeStationsFromData(data!);
                
                dispatch_async(dispatch_get_main_queue()) {
                    if bikeStations != nil {
                        self.delegate?.datasetFetcher(self, didFetchBikeStations: bikeStations!)
                    } else {
                        self.delegate?.datasetFetcher(self, didFailWithMessage: "Failed to decode result.");
                    }
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.datasetFetcher(self, didFailWithMessage: error!.localizedDescription);
                }
            }
        }
        
        _urlSessionDataTask = task;
        task.resume()
        
        return true
    }
    
    func cancelCurrentTask() {
        if _urlSessionDataTask != nil {
            _urlSessionDataTask!.cancel()
        }
    }
    
    private func parseBikeStationsFromData(data: NSData) -> Array<MBSBikeStation>? {
        var dataDict: Dictionary<String, AnyObject>!
        do {
            let readingOptions = NSJSONReadingOptions() // default options
            dataDict = try NSJSONSerialization.JSONObjectWithData(data, options: readingOptions) as? Dictionary
        } catch {
            return nil;
        }
        
        let stationArray = dataDict["data"] as? Array<Array<AnyObject>>;
        
        if stationArray == nil {
            return nil
        }
        
        var stations: [MBSBikeStation] = []

        for station in stationArray! {
            let featureName = station[9] as! String
            let numberOfBikes = Int(station[11] as! String)!
            let latitude = Double((station[14] as! Array<AnyObject>)[1] as! String)!
            let longitude = Double((station[14] as! Array<AnyObject>)[2] as! String)!
            
            let coordiate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let bs = MBSBikeStation(featureName: featureName,
                                  numberOfBikes: numberOfBikes,
                                     coordinate: coordiate)
            stations.append(bs)
        }
        
        return stations
    }
}
