//
//  MBSuggestionBoxTests.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 11/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import XCTest

@testable import MelbourneBikeShare

class MBSuggestionBoxTests: XCTestCase {
    
    func test_prefixFilter_mustMatch_properSuggestions_1() {
        
        // Given:
        let suggestionBox = createSuggestionBox(withStrings: [
            "Bridport St",
            "Cleve Gardens",
            "Coventry St / Clarendon St",
            "Coventry St / St Kilda Rd",
            "Domain Interchange",
            "Federation Square",
            "Fitzroy Street",
            "Fitzroy Town Hall",
        ])
        
        // When:
        suggestionBox.prefixFilter = "C"
        
        // Then: must match
        //      "Cleve Gardens",
        //      "Coventry St / Clarendon St",
        //      "Coventry St / St Kilda Rd",
        let filteredSuggestion = suggestionBox.filteredSuggestions
        XCTAssertEqual(filteredSuggestion.count, 3)
        XCTAssertEqual(filteredSuggestion[0].text, "Cleve Gardens")
        XCTAssertEqual(filteredSuggestion[1].text, "Coventry St / Clarendon St")
        XCTAssertEqual(filteredSuggestion[2].text, "Coventry St / St Kilda Rd")
    }
    
    func test_prefixFilter_mustMatch_properSuggestions_2() {
        
        // Given:
        let suggestionBox = createSuggestionBox(withStrings: [
            "Bridport St",
            "Cleve Gardens",
            "Coventry St / Clarendon St",
            "Coventry St / St Kilda Rd",
            "Domain Interchange",
            "Federation Square",
            "Fitzroy Street",
            "Fitzroy Town Hall",
        ])
        
        // When:
        suggestionBox.prefixFilter = "Co"
        
        // Then: must match
        //      "Coventry St / Clarendon St",
        //      "Coventry St / St Kilda Rd",
        let filteredSuggestion = suggestionBox.filteredSuggestions
        XCTAssertEqual(filteredSuggestion.count, 2)
        XCTAssertEqual(filteredSuggestion[0].text, "Coventry St / Clarendon St")
        XCTAssertEqual(filteredSuggestion[1].text, "Coventry St / St Kilda Rd")
    }
    
    func test_prefixFilter_mustMatch_properSuggestions_3() {
        
        // Given:
        let suggestionBox = createSuggestionBox(withStrings: [
            "Bridport St",
            "Cleve Gardens",
            "Coventry St / Clarendon St",
            "Coventry St / St Kilda Rd",
            "Domain Interchange",
            "Federation Square",
            "Fitzroy Street",
            "Fitzroy Town Hall",
        ])
        
        // When:
        suggestionBox.prefixFilter = "Coventry St / S"
        
        // Then: must match
        //      "Coventry St / St Kilda Rd",
        let filteredSuggestion = suggestionBox.filteredSuggestions
        XCTAssertEqual(filteredSuggestion.count, 1)
        XCTAssertEqual(filteredSuggestion[0].text, "Coventry St / St Kilda Rd")
    }
    
    func test_nonMatchingPrefix_mustMatch_nothing_1() {
        
        // Given:
        let suggestionBox = createSuggestionBox(withStrings: [
            "Bridport St / Montague St - Albert Park",
            "Cleve Gardens - Fitzroy St - St Kilda",
            "Coventry St / Clarendon St - South Melbourne",
            "Coventry St / St Kilda Rd - Southbank",
            "Domain Interchange - Park St / St Kilda Rd - Melbourne",
            "Federation Square - Flinders St / Swanston St - City",
            "Fitzroy Street - St Kilda",
            "Fitzroy Town Hall - Moor St - Fitzroy",
        ])
        
        // When:
        suggestionBox.prefixFilter = "A"
        
        // Then: must match nothing
        XCTAssertEqual(suggestionBox.filteredSuggestions.count, 0)
    }
    
    func test_nonMatchingPrefix_mustMatch_nothing_2() {
        
        // Given:
        let suggestionBox = createSuggestionBox(withStrings: [
            "Bridport St / Montague St - Albert Park",
            "Cleve Gardens - Fitzroy St - St Kilda",
            "Coventry St / Clarendon St - South Melbourne",
            "Coventry St / St Kilda Rd - Southbank",
            "Domain Interchange - Park St / St Kilda Rd - Melbourne",
            "Federation Square - Flinders St / Swanston St - City",
            "Fitzroy Street - St Kilda",
            "Fitzroy Town Hall - Moor St - Fitzroy",
            ])
        
        // When:
        suggestionBox.prefixFilter = "Fitzrox"
        
        // Then: must match nothing
        XCTAssertEqual(suggestionBox.filteredSuggestions.count, 0)
    }
    
    func test_prefixFilter_prefixedBySuggestion_mustNotMatch() {
        // prefixFilter must be a prefix of suggestion,
        // not the other way around
        
        // Given:
        let suggestionBox = createSuggestionBox(withStrings: [
            "Bridport",
        ])
        
        // When:
        suggestionBox.prefixFilter = "Bridport St / Montague St - Albert Park"
        
        // Then: must match nothing
        XCTAssertEqual(suggestionBox.filteredSuggestions.count, 0)
    }
    
    func test_prefixFilter_mustBeMatched_caseInsensitively() {
        
        // Given:
        let strings = [
            "ACCA - Sturt St - Southbank",
            "acca - sturt st - southbank",
            "ABCD - Sturt St - Southbank",
        ]
        
        let suggestions   = createSuggestions(withStrings: strings)
        let suggestionBox = createSuggestionBox(withSuggestions: suggestions)
        
        // When:
        suggestionBox.prefixFilter = "aCcA"
        
        // Then: must match
        //       "ACCA - Sturt St - Southbank"
        //       "acca - sturt st - southbank"
        let filteredSuggestion = suggestionBox.filteredSuggestions
        XCTAssertEqual(filteredSuggestion.count, 2)
        XCTAssertEqual(filteredSuggestion[0].text, "ACCA - Sturt St - Southbank")
        XCTAssertEqual(filteredSuggestion[1].text, "acca - sturt st - southbank")
    }
    
    func test_emptyPrefixFilter_mustMatch_allSuggestions() {
        
        // Given:
        let suggestions = createSuggestions(withStrings: [
            "ACCA - Sturt St - Southbank",
            "ANZ - Collins St - Docklands",
            "Aquarium - Kings Way / Flinders St - City",
            "Argyle Square - Lygon St - Carlton",
            "Beach St - Port Melbourne",
            "Bourke Street Mall - 205 Bourke St - City",
            "Bridport St / Montague St - Albert Park",
            "Cleve Gardens - Fitzroy St - St Kilda",
            "Coventry St / Clarendon St - South Melbourne",
            "Coventry St / St Kilda Rd - Southbank",
            "Domain Interchange - Park St / St Kilda Rd - Melbourne",
            "Federation Square - Flinders St / Swanston St - City",
            "Fitzroy Street - St Kilda",
            "Fitzroy Town Hall - Moor St - Fitzroy",
            "Flagstaff Gardens - Peel St - West Melbourne",
            "Gasworks Arts Park - Pickles St - Albert Park",
            "Harbour Town - Docklands Dve - Docklands",
            "Jolimont Station - Wellington Pde South - East Melbourne",
            "Kings Way / St Kilda Rd - Melbourne",
            "Luna Park - Lower Esp - St Kilda",
            "Melbourne Uni - Tin Alley - Carlton",
            "MSAC - Aughtie Dve - Albert Park",
            "Museum - Rathdowne St - Carlton",
            "NAB - Harbour Esp / Bourke St - Docklands"
        ])
        
        let suggestionBox = createSuggestionBox(withSuggestions: suggestions)
        
        // When:
        suggestionBox.prefixFilter = ""
        
        // Then: must show all suggestions
        XCTAssertEqual(suggestionBox.filteredSuggestions, suggestions)
    }
}



// MARK: - Helper Functions

func createSuggestions(withStrings strings: Array<String>) -> Array<MBSSuggestion> {
    var suggestions = Array<MBSSuggestion>()
    
    for string in strings {
        let suggestion = MBSSuggestion(text: string, hint: "")
        suggestions.append(suggestion)
    }
    
    return suggestions
}

func createSuggestionBox(withSuggestions suggestions: Array<MBSSuggestion>) -> MBSSuggestionBox {
    
    let ORDINARY_FRAME = CGRect(x: 0, y: 0, width: 100, height: 200)
    let suggestionBox = MBSSuggestionBox(frame: ORDINARY_FRAME)
    
    suggestionBox.setSuggestions(suggestions)
    
    return suggestionBox
}

func createSuggestionBox(withStrings strings: Array<String>) -> MBSSuggestionBox {
    let suggestions = createSuggestions(withStrings: strings)
    return createSuggestionBox(withSuggestions: suggestions)
}
