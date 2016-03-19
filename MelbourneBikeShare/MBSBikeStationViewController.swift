//
//  MBSBikeStationViewController.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 4/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class MBSBikeStationViewController: UIViewController,
                                    UITextFieldDelegate,
                                    GMSMapViewDelegate,
                                    MBSDatasetFetcherDelegate,
                                    MBSSuggestionBoxDelegate {
    
    @IBOutlet private weak var _mapView:       GMSMapView?
    @IBOutlet private weak var _overlayView:   UIView?
    @IBOutlet private weak var _searchArea:    UIView?
    @IBOutlet private weak var _searchBox:     UITextField?
    @IBOutlet private weak var _suggestionBox: MBSSuggestionBox?
    @IBOutlet private weak var _refreshButton: MBSAnimationButton?
    
    private let _datasetFetcher = MBSDatasetFetcher()
    private var _bikeStationMarkers: Array<MBSBikeStationMarker>?
    
    private struct SearchArea {
        static let ANIMATION_DURATION = 0.5
        static let ACTIVE_ALPHA:   CGFloat = 1.0
        static let INACTIVE_ALPHA: CGFloat = 0.8
    }
    
    private struct OverlayView {
        static let ACTIVE_ALPHA:   CGFloat = 0.7
        static let INACTIVE_ALPHA: CGFloat = 0.0
    }
    
    private struct SuggestionBox {
        static let ACTIVE_ALPHA:   CGFloat = 1.0
        static let INACTIVE_ALPHA: CGFloat = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _datasetFetcher.delegate = self
        
        setupMapView(_mapView!)
        setupOverlayView(_overlayView!)
        setupSearchArea(_searchArea!)
        setupSuggestionBox(_suggestionBox!)
        
        refreshBikeStations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - View setup utilities
    
    private func setupMapView(mapView: GMSMapView) {
        
        let settings = MBSSettings.sharedInstance
        var camera = settings.defaultCameraPosition()
        
        if camera == nil {
            // Fallback to default: Melbourne (-37.8132, 144.963)
            camera = GMSCameraPosition.cameraWithLatitude(-37.8132, longitude: 144.963, zoom: 13)
        }
        
        mapView.camera = camera!
        mapView.delegate = self
    }
    
    private func setupOverlayView(overlayView: UIView) {
        overlayView.alpha = OverlayView.INACTIVE_ALPHA
        overlayView.userInteractionEnabled = false
    }
    
    private func setupSearchArea(searchArea: UIView) {
        searchArea.alpha = SearchArea.INACTIVE_ALPHA
        
        // border radius
        searchArea.layer.cornerRadius = 2.5;
        
        // drop shadow
        searchArea.layer.shadowColor = UIColor.grayColor().CGColor
        searchArea.layer.shadowOpacity = 0.8
        searchArea.layer.shadowRadius = 2.0
        searchArea.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
    
    private func setupSuggestionBox(suggestionBox: MBSSuggestionBox) {
        suggestionBox.delegate = self;
        suggestionBox.alpha = SuggestionBox.INACTIVE_ALPHA
        
        let layer = suggestionBox.layer;
        
        // border radius
        layer.cornerRadius = 2.0;
        
        // border
        //layer.borderColor = UIColor.grayColor().CGColor
        layer.borderWidth = 0;
        
        // drop shadow
        layer.shadowColor = UIColor.grayColor().CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - MBSDatasetFetcher - searchBox
    
    func datasetFetcher(datasetFetcher: MBSDatasetFetcher, didFetchBikeStations bikeStations: Array<MBSBikeStation>) {
        
        _refreshButton!.endAnimation()
        _refreshButton!.userInteractionEnabled = true
        
        let sortedBikeStations = bikeStations.sort { (bs1, bs2) -> Bool in
            return bs1.featureName.caseInsensitiveCompare(bs2.featureName) == .OrderedAscending
        }
        
        refreshMarkers(withBikeStations: sortedBikeStations)
        refreshSuggestionBox(withBikeStations: sortedBikeStations)
    }
    
    func datasetFetcher(datasetFetcher: MBSDatasetFetcher, didFailWithMessage message: String) {

        _refreshButton!.endAnimation()
        _refreshButton!.userInteractionEnabled = true
        
        let alert = UIAlertController(title: NSLocalizedString("TITLE_ERROR", comment: "Alert title"),
                                    message: message,
                             preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("LABEL_OK", comment: "OK button label"),
                                      style: UIAlertActionStyle.Default,
                                    handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - MBSSuggestionBoxDelegate - searchBox
    
    func suggestionBox(suggestionBox: MBSSuggestionBox, didSelectSuggestion suggestion: MBSSuggestion, atIndex index: Int) {
        let marker = _bikeStationMarkers![index]
        
        _mapView!.selectedMarker = marker
        
        let camera = GMSCameraPosition.cameraWithLatitude(marker.position.latitude,
                                                longitude:marker.position.longitude,
                                                     zoom:15)
        
        _mapView!.animateToCameraPosition(camera)

        _searchBox!.resignFirstResponder()
        _searchBox!.text = marker.title
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - UITextFieldDelegate - searchBox
    
    func textFieldDidBeginEditing(textField: UITextField) {

        _suggestionBox!.prefixFilter = textField.text!
        
        UIView.animateWithDuration(SearchArea.ANIMATION_DURATION, animations: {
            self._overlayView?.alpha = SearchArea.ACTIVE_ALPHA
            self._overlayView?.alpha = OverlayView.ACTIVE_ALPHA
            self._suggestionBox?.alpha = SuggestionBox.ACTIVE_ALPHA
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        UIView.animateWithDuration(SearchArea.ANIMATION_DURATION, animations: {
            self._searchArea?.alpha = SearchArea.INACTIVE_ALPHA
            self._overlayView?.alpha = OverlayView.INACTIVE_ALPHA
            self._suggestionBox?.alpha = SuggestionBox.INACTIVE_ALPHA
        })
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text!
        let subRange = Range<String.Index>(start: text.startIndex.advancedBy(range.location),
                                             end: text.startIndex.advancedBy(range.location + range.length))
        let prefix = text.stringByReplacingCharactersInRange(subRange, withString: string)
        _suggestionBox!.prefixFilter = prefix
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        _suggestionBox!.prefixFilter = ""
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - GMSMapViewDelegate - mapView
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if _searchBox!.isFirstResponder() {
            _searchBox!.resignFirstResponder()
        }
    }
    
    func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        if marker.isKindOfClass(MBSBikeStationMarker) {
            return (marker as! MBSBikeStationMarker).createInfoContents()
        }
        return nil
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        launchNavigationApp(withMarker: marker)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Refresh Button Handler

    @IBAction
    func refreshButtonPressed(button: UIButton) {
        refreshBikeStations()
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - General Utilities
    
    private func refreshBikeStations() {
        if _datasetFetcher.fetchBikeStations() {
            _refreshButton!.userInteractionEnabled = false;
            _refreshButton!.beingAnimation()
        }
    }
    
    private func launchNavigationApp(withMarker marker: GMSMarker) {

        let regionDistance: CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(marker.position, regionDistance, regionDistance)
        let placemark = MKPlacemark(coordinate: marker.position, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = marker.title
        mapItem.openInMapsWithLaunchOptions([
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
            ])
    }
    
    private func refreshMarkers(withBikeStations bikeStations: Array<MBSBikeStation>) {
        
        _mapView!.clear()
        _bikeStationMarkers = Array<MBSBikeStationMarker>()
        
        for bikeStation in bikeStations {
            
            let marker = MBSBikeStationMarker(bikeStation: bikeStation)
            
            marker.map = self._mapView
            
            _bikeStationMarkers!.append(marker)
        }
    }
    
    private func refreshSuggestionBox(withBikeStations bikeStations: Array<MBSBikeStation>) {
        var suggestions = Array<MBSSuggestion>()
        
        for bikeStation in bikeStations {
            let components = bikeStation.featureName.componentsSeparatedByString(" - ")
            var suggestion: MBSSuggestion
            
            if components.count == 3 {
                let title = components[0]
                let street = components[1]
                let suburb = components[2]
                suggestion = MBSSuggestion(text: title, hint: "\(street), \(suburb)")
            } else if components.count == 2 {
                let street = components[0]
                let suburb = components[1]
                suggestion = MBSSuggestion(text: street, hint: "\(street), \(suburb)")
            } else {
                suggestion = MBSSuggestion(text: bikeStation.featureName, hint: "")
            }
            
            suggestions.append(suggestion)
        }
        
        _suggestionBox!.setSuggestions(suggestions)
    }
    
    

    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Keyboard Management Methods
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        notificationCenter.addObserver(self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        let SPACING: CGFloat = 35.0
        
        let info: NSDictionary = sender.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.CGRectValue().size
        let keyboardHeight = keyboardSize.height
        
        print("keyboardWillShow", self.view.frame.height, keyboardHeight)
        
        for constraint in self.view.constraints {
            if constraint.identifier == "SuggestionBottom" {
                constraint.constant = keyboardHeight + SPACING
                break
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        print("keyboardWillHide")
    }
}
