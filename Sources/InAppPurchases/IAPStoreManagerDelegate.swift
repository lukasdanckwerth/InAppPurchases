//
//  StoreManagerDelegate.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - StoreManagerDelegate

public protocol StoreManagerDelegate: AnyObject {
    
    // MARK: - Requests
    
    /// Tells the delegate that the request was successful.
    ///
    func requestDidFinish(_ request: SKRequest)
    
    /// Called when the product request failed.
    ///
    func request(_ request: SKRequest, didFailWithError error: Error)
    
    // MARK: -  ProductRequest
    
    /// Provides the delegate with the App Store's response.
    ///
    func didReceive(products: [SKProduct], invalidIdentifiers: [String])
    
    // MARK: - Transaction
    
    /// Tells the delegate that the transaction did start purchasing.
    ///
    func purchasing(_ transaction: SKPaymentTransaction)
    
    /// Tells the delegate that the transaction deferred.
    ///
    func deferred(_ transaction: SKPaymentTransaction)
    
    /// Tells the delegate that the transaction was purchased successful.
    ///
    func purchased(_ transaction: SKPaymentTransaction)
    
    /// Tells the delegate that the transaction was restored successful.
    ///
    func restored(_ transaction: SKPaymentTransaction)
    
    /// Tells the delegate that an error occured with the transaction.
    ///
    func failed(_ transaction: SKPaymentTransaction)
    
    /// Tells the delegate that the user canceled the transaction.
    ///
    func canceled(_ transaction: SKPaymentTransaction)
    
    // MARK: - Restore
    
    /// Tells the delegate that the restoration of the transaction is finished.
    ///
    func restoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
    
    /// Tells the delegate that the restoration of the transation did failed with specified error.
    ///
    func restoreCompletedTransactionsFailedWithError(_ error: SKError?)
    
    /// Tells the delegate that the restoration of the transation was canceled by user with specified error.
    ///
    func restoreCompletedTransactionsCanceled(_ error: SKError)   
}
