//
//  MBSBikeStationMarkerTests.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 6/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import XCTest
import MapKit

@testable import MelbourneBikeShare

class MBSBikeStationMarkerTests: XCTestCase {
    
    // The size of the circle is related to the number of bikes available.
    // Thus, a marker with larger numberOfBikes should have larger
    // circle icon.
    
    func test_sizeOfIcon_mustBe_proportionalTo_numberOfBikes() {
        var bikeStations: Array<MBSBikeStation> = []
        
        let MIN_NUM_BIKES: Int = 0
        let MAX_NUM_BIKES: Int = 100
        
        for var i = MIN_NUM_BIKES; i < MAX_NUM_BIKES; i += 1 {
            let bs = createBikeStation(withNumberOfBikes: i)
            bikeStations.append(bs)
        }
        
        var prevMarker: MBSBikeStationMarker?
        
        for bs in bikeStations {
            let marker = MBSBikeStationMarker(bikeStation: bs)
            if prevMarker == nil {
                prevMarker = marker
                continue
            }
            
            let prevIcon = prevMarker!.icon!
            let icon     = marker.icon!
            
            let prevIconArea = prevIcon.size.width * prevIcon.size.height
            let iconArea     = icon.size.width * icon.size.height
            
            XCTAssertLessThanOrEqual(prevIconArea, iconArea)
        }
    }
}

// MARK: - Helper Functions

func createBikeStation(withNumberOfBikes numberOfBikes: Int) -> MBSBikeStation {
    return MBSBikeStation(featureName: "Station - \(numberOfBikes)",
                        numberOfBikes: numberOfBikes,
                           coordinate: CLLocationCoordinate2D())
}
