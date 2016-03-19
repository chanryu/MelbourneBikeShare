//
//  MBSSuggestionBox.swift
//  MelbourneBikeShare
//
//  Created by Chan Ryu on 4/03/2016.
//  Copyright © 2016 Homepass. All rights reserved.
//

import UIKit

class MBSSuggestion: Equatable {
    var text: String
    var hint: String

    init(text: String, hint: String) {
        self.text = text
        self.hint = hint
    }
}

func == (lhs: MBSSuggestion, rhs: MBSSuggestion) -> Bool {
    return lhs.text == rhs.text && lhs.hint == rhs.hint
}

protocol MBSSuggestionBoxDelegate : NSObjectProtocol {
    func suggestionBox(suggestionBox: MBSSuggestionBox, didSelectSuggestion suggestion: MBSSuggestion, atIndex index: Int)
}

class MBSSuggestionBox: UIView, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: MBSSuggestionBoxDelegate?
    
    private let _tableView = UITableView()
    private let _messageLabel = UILabel()
    
    private var _prefixFilter = ""
    private var _allSuggestions = Array<MBSSuggestion>()
    private var _filteredSuggestions = Array<MBSSuggestion>()
    
    var filteredSuggestions: Array<MBSSuggestion> {
        get {
            return _filteredSuggestions
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: -
    
    func initSubviews() {
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.frame = self.bounds
        _tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(_tableView)
        
        _messageLabel.hidden = true
        _messageLabel.text = "No match found"
        _messageLabel.textColor = UIColor.grayColor()
        _messageLabel.sizeToFit()
        _messageLabel.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin,
                                          .FlexibleLeftMargin, .FlexibleRightMargin]
        addSubview(_messageLabel)
    }
    
    
    
    var prefixFilter: String {
        set {
            var prefixFilter = newValue
            if prefixFilter.characters.count > 0 {
                prefixFilter = prefixFilter.lowercaseString
                
                _filteredSuggestions = Array<MBSSuggestion>()
                for suggestion in _allSuggestions {
                    if suggestion.text.lowercaseString.hasPrefix(prefixFilter) {
                        _filteredSuggestions.append(suggestion)
                    }
                }
            } else {
                _filteredSuggestions = _allSuggestions
            }
            
            _tableView.reloadData()
            
            if _filteredSuggestions.count == 0 {
                _tableView.hidden = true
                _messageLabel.hidden = false
                _messageLabel.center = CGPoint(x: self.bounds.width  / 2,
                    y: self.bounds.height / 2)
            } else {
                _tableView.hidden = false
                _messageLabel.hidden = true
            }
        }
        get {
            return _prefixFilter
        }
    }
    
    func setSuggestions(suggestions: Array<MBSSuggestion>) {
        _allSuggestions = suggestions
        _filteredSuggestions = suggestions
        _tableView.reloadData()
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _filteredSuggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        assert(indexPath.row >= 0)
        assert(indexPath.row < _filteredSuggestions.count)
        
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "")
        
        let suggestion = _filteredSuggestions[indexPath.row]
        
        cell.textLabel!.text = suggestion.text
        
        cell.detailTextLabel!.text = suggestion.hint
        cell.detailTextLabel!.textColor = UIColor.grayColor()
        
        return cell
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        assert(indexPath.row >= 0)
        assert(indexPath.row < _filteredSuggestions.count)
        
        let selectedSuggestion = _filteredSuggestions[indexPath.row]
        var index: Int
        
        if _allSuggestions.count == _filteredSuggestions.count {
            index = indexPath.row
        } else {
            // convert filtered index to real index
            index = 0
            for suggestion in _allSuggestions {
                if suggestion === selectedSuggestion {
                    break
                }
                index += 1
            }
        }
        
        delegate?.suggestionBox(self, didSelectSuggestion: selectedSuggestion, atIndex: index)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
