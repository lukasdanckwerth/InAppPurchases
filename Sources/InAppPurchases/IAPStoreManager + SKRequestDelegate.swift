//
//  IAPStoreManager + SKRequestDelegate.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 16.03.22.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import Foundation
import StoreKit

/// Extends StoreManager to conform to SKRequestDelegate.
///
extension IAPStoreManager: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        executeAsync { self.delegate?.requestDidFinish(request) }
    }
    
    /// Called when the product request failed.
    ///
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        executeAsync { self.delegate?.request(request, didFailWithError: error) }
    }
}
