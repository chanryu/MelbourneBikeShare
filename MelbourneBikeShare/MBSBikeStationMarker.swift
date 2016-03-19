//
//  MBSBikeStationMarker.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 6/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import GoogleMaps

class MBSBikeStationMarker: GMSMarker {
    
    let bikeStation: MBSBikeStation
    
    init(bikeStation: MBSBikeStation) {
        
        self.bikeStation = bikeStation
        
        super.init()
        
        let components = bikeStation.featureName.componentsSeparatedByString(" - ")
        
        switch components.count {
        case 3:
            let title = components[0]
            let street = components[1]
            let suburb = components[2]
            self.title = title
            self.snippet = "\(street), \(suburb)"
        case 2:
            let street = components[0]
            let suburb = components[1]
            self.title = street
            self.snippet = "\(street), \(suburb)"
        default:
            self.title = bikeStation.featureName
            self.snippet = ""
        }
        
        self.position = bikeStation.coordinate
        self.icon = createCircleIcon()
        self.groundAnchor = CGPoint(x: 0.5, y: 0.5) // anchor in icon center
        self.appearAnimation = kGMSMarkerAnimationPop
    }
    
    func createInfoContents() -> UIView {
        let ICON_WIDTH:  CGFloat = 38
        let ICON_HEIGHT: CGFloat = 34
        let ICON_MARGIN: CGFloat = 6
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: ICON_WIDTH, height: ICON_HEIGHT))
        iconView.image = UIImage(named: "VehicleOnBlue")
        iconView.contentMode = .Center
        iconView.backgroundColor = UIColor(red: 21 / 255.0, green: 126 / 255.0, blue: 251 / 255.0, alpha: 1)
        iconView.layer.cornerRadius = 3.0;
        
        let titleLabel = UILabel(frame: CGRect.zero)
        let snippetLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.text = self.title
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleLabel.sizeToFit()
        titleLabel.frame = titleLabel.frame.offsetBy(dx: ICON_WIDTH + ICON_MARGIN, dy: 0)
        
        snippetLabel.text = self.snippet
        snippetLabel.textColor = UIColor.grayColor()
        snippetLabel.font = UIFont.systemFontOfSize(14)
        snippetLabel.sizeToFit()
        snippetLabel.frame = snippetLabel.frame.offsetBy(dx: ICON_WIDTH + ICON_MARGIN, dy: titleLabel.frame.maxY)
        
        let w = ICON_WIDTH + ICON_MARGIN + max(titleLabel.frame.width, snippetLabel.frame.width)
        let h = titleLabel.frame.height + snippetLabel.frame.height
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        
        view.addSubview(iconView)
        view.addSubview(titleLabel)
        view.addSubview(snippetLabel)
        
        return view;
    }
    
    private func createCircleIcon() -> UIImage {
        
        let MAX_CIRCLE_RADIUS: CGFloat = 40.0
        let MIN_CIRCLE_RADIUS: CGFloat = 15.0
        
        var radius = CGFloat(bikeStation.numberOfBikes) / CGFloat(25.0) * MAX_CIRCLE_RADIUS;
        
        radius = min(radius, CGFloat(MAX_CIRCLE_RADIUS))
        radius = max(radius, CGFloat(MIN_CIRCLE_RADIUS))
        
        let circleSize = CGSize(width: radius * 2, height: radius * 2)
        let circleRect = CGRect(origin: CGPoint.zero, size: circleSize)
        let screenScale = UIScreen.mainScreen().scale
        
        //let circleColor = UIColor.redColor()
        let circleColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        
        UIGraphicsBeginImageContextWithOptions(circleSize, false, screenScale)
        let context = UIGraphicsGetCurrentContext()!
        
        circleColor.colorWithAlphaComponent(0.6).setFill()
        CGContextFillEllipseInRect(context, circleRect)
        
        circleColor.setStroke()
        CGContextStrokeEllipseInRect(context, circleRect.insetBy(dx: 1.0 / screenScale, dy: 1.0 / screenScale))
        
        let numberOfBikes: NSString = "\(bikeStation.numberOfBikes)"
        
        let fontSize = 15.5 * (radius / MIN_CIRCLE_RADIUS)
        var font = UIFont(name: "TrebuchetMS", size: fontSize)
        if font == nil {
            font = UIFont.systemFontOfSize(fontSize)
        }
        
        let textAttributes = [
            NSFontAttributeName: font!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        let textBounds = numberOfBikes.boundingRectWithSize(circleSize, options: NSStringDrawingOptions(), attributes: textAttributes, context: nil)
        let textRect = circleRect.offsetBy(dx: (circleRect.size.width  - textBounds.size.width)  / 2,
            dy: (circleRect.size.height - textBounds.size.height) / 2)
        
        numberOfBikes.drawInRect(textRect, withAttributes: textAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
