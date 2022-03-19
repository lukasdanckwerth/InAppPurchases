//
//  StoreManager + Buy.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 13.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import StoreKit
import Foundation

/// Extends StoreObserver to conform to SKPaymentTransactionObserver.
///
extension IAPStoreManager {
    
    /// Indicates whether the user is allowed to make payments.
    ///
    /// - returns: true if the user is allowed to make payments and false, otherwise. Tell StoreManager to query the App Store when the user is
    /// allowed to make payments and there are product identifiers to be queried.
    ///
    public var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// Create and add a payment request to the payment queue.
    ///
    func buy(_ product: SKProduct) {
        SKPaymentQueue.default().add(SKMutablePayment(product: product))
    }
    
    /// Restores all previously completed purchases.
    ///
    func restore() {
        if !purchased.isEmpty { purchased.removeAll() }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
