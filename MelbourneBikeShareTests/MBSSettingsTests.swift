//
//  MBSSettingsTests.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 6/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import XCTest

@testable import MelbourneBikeShare

class MBSSettingsTests: XCTestCase {
    
    private var _settings = MBSSettings.sharedInstance

    func test_settings_mustHave_googleApiKey() {
        let googleApiKey = _settings.stringForKey(MBSSettings.Key.GOOGLE_API_KEY)
        XCTAssertNotNil(googleApiKey)
    }
    
    func test_settings_mustHave_BikeShareUrl() {
        let bikeShareUrl = _settings.stringForKey(MBSSettings.Key.BIKE_SHARE_URL)
        XCTAssertNotNil(bikeShareUrl)
    }
    
    func test_bikeShreUrl_mustBe_welformed() {
        let bikeShareUrl = _settings.stringForKey(MBSSettings.Key.BIKE_SHARE_URL)
        let candidateURL = NSURL(string: bikeShareUrl!)
        
        // when bikeShareUrl is not valid, NSURL(string:) returns nil
        XCTAssert(candidateURL != nil)
    }
    
    func test_settings_mustHave_validDefaultCameraPosition() {
        let camPos = _settings.defaultCameraPosition()
        XCTAssertNotNil(camPos)
    }
}
