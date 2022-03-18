//
//  StoreManager + SKProductsRequestDelegate.swift
//  
//
//  Created by Lukas Danckwerth on 16.03.22.
//

import Foundation
import StoreKit

/// Extends StoreManager to conform to SKProductsRequestDelegate.
///
extension IAPStoreManager: SKProductsRequestDelegate {
    
    /// Used to get the App Store's response to your request and notify your observer.
    ///
    /// - Tag: ProductRequest
    ///
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // products contains products whose identifiers have been
        // recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
            availableProducts = response.products
        }
        
        // invalidProductIdentifiers contains all product identifiers
        // not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
            invalidProductIdentifiers = response.invalidProductIdentifiers
        }
        
        executeAsync {
            self.delegate?.didReceive(
                products: self.availableProducts,
                invalidIdentifiers: self.invalidProductIdentifiers
            )
        }
    }
}
