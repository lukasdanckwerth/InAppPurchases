//
//  StoreManager + TransactionObserver.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import StoreKit
import Foundation

func executeAsync(execute: @escaping () -> Void) {
    DispatchQueue.main.async(execute: execute)
}


/// Extends StoreObserver to conform to SKPaymentTransactionObserver.
///
extension IAPStoreManager: SKPaymentTransactionObserver {
    
    // MARK: - SKPaymentTransactionObserver
    
    /// Called when there are transactions in the payment queue.
    ///
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                purchasing(transaction)
            case .deferred:
                deferred(transaction)
            case .purchased:
                purchased(transaction)
            case .restored:
                restored(transaction)
            case .failed:
                failed(transaction)
            @unknown default:
                fatalError("unknown payment transaction")
            }
        }
    }
    
    /// Logs all transactions that have been removed from the payment queue.
    ///
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        // for transaction in transactions { print("\(transaction.payment.productIdentifier) removed") }
    }
    
    /// Called when an error occur while restoring purchases. Notify the user about the error.
    ///
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        if let error = error as? SKError, error.code != .paymentCancelled {
            executeAsync { self.delegate?.restoreCompletedTransactionsCanceled(error) }
        } else {
            executeAsync { self.delegate?.restoreCompletedTransactionsFailedWithError(error as? SKError) }
        }
    }
    
    /// Called when all restorable transactions have been processed by the payment queue.
    ///
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        executeAsync { self.delegate?.restoreCompletedTransactionsFinished(queue) }
    }
    
    
    
    // MARK: - Handle Payment Transactions
    
    /// Handles start of purchasing a transaction.
    ///
    private func purchasing(_ transaction: SKPaymentTransaction) {
        executeAsync { self.delegate?.purchasing(transaction) }
    }
    
    /// Handles deferred of a transaction.
    ///
    private func deferred(_ transaction: SKPaymentTransaction) {
        executeAsync { self.delegate?.deferred(transaction) }
    }
    
    /// Handles successful purchase transactions.
    ///
    private func purchased(_ transaction: SKPaymentTransaction) {
        purchased.append(transaction)
        addLocal(purchasedProductIdentifier: transaction.payment.productIdentifier)
        executeAsync { self.delegate?.purchased(transaction) }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Handles restored purchase transactions.
    ///
    private func restored(_ transaction: SKPaymentTransaction) {
        purchased.append(transaction)
        addLocal(purchasedProductIdentifier: transaction.payment.productIdentifier)
        executeAsync { self.delegate?.restored(transaction) }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Handles failed purchase transactions.
    ///
    private func failed(_ transaction: SKPaymentTransaction) {

        if (transaction.error as? SKError)?.code == .paymentCancelled {
            executeAsync { self.delegate?.canceled(transaction) }
        } else {
            executeAsync { self.delegate?.failed(transaction) }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
