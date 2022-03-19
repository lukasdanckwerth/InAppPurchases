//
//  UITableViewCell + Extension.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 16.03.22.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIView {
    
    /// Returns the firs found activity indicator view (or nil) from the collection of subviews.
    ///
    var activityIndicatorView: UIActivityIndicatorView? {
        return subviews.compactMap({ $0 as? UIActivityIndicatorView }).first
    }
}

@objc extension UITableViewCell {
    
    override var activityIndicatorView: UIActivityIndicatorView? {
        return super.activityIndicatorView ?? contentView.activityIndicatorView
    }
    
    /// Returns the parental view controller.
    ///
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    /// Whether the activity indicator view is visible.
    ///
    var isLoading: Bool {
        get {
            return activityIndicatorView != nil
        } set {
            if newValue {
                if activityIndicatorView == nil {
                    
                    let newActivityIndicator: UIActivityIndicatorView
                    if #available(iOS 13.0, *) {
                        newActivityIndicator = UIActivityIndicatorView(style: .medium)
                    } else {
                        newActivityIndicator = UIActivityIndicatorView(style: .gray)
                    }
                    
                    newActivityIndicator.tintColor = parentViewController?.view.tintColor
                    newActivityIndicator.color = parentViewController?.view.tintColor
                    
                    newActivityIndicator.startAnimating()
                    accessoryView = newActivityIndicator
                }
            } else {
                activityIndicatorView?.removeFromSuperview()
                accessoryView = nil
            }
        }
    }
}
