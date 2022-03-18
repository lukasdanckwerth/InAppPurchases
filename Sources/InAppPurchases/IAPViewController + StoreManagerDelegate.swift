//
//  IAPViewController + StoreManagerDelegate.swift
//  IAPViewController
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import Foundation
import StoreKit

extension IAPViewController: StoreManagerDelegate {
    
    // MARK: - Requests
    
    public func requestDidFinish(_ request: SKRequest) {
        hideLoading()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        hideLoading()
        presentAlert(
            title: NSLocalizedString("IAPViewController.RequestError.Title", comment: ""),
            message: NSLocalizedString("IAPViewController.RequestError.Message", comment: ""),
            error: error
        )
    }
    
    // MARK: - Product Requests
    
    public func didReceive(products: [SKProduct], invalidIdentifiers: [String]) {
        self.availableProducts = products
        self.invalidIdentifiers = invalidIdentifiers
    }
    
    // MARK: - Transactions
    
    /// Handles start purchasing a transaction.
    ///
    public func purchasing(_ transaction: SKPaymentTransaction) {
        disableUserInterface()
    }
    
    /// Handles deferred transaction.
    ///
    public func deferred(_ transaction: SKPaymentTransaction) {
        // empty
    }
    
    /// Handles successful purchase transaction.
    ///
    public func purchased(_ transaction: SKPaymentTransaction) {
        self.purchased = IAPStoreManager.shared.purchased
        if tableView.window != nil { tableView.reloadData() }
        delegate?.didPurchase(productIdentifier: transaction.payment.productIdentifier)
    }
    
    /// Handles restored restoration transaction.
    ///
    public func restored(_ transaction: SKPaymentTransaction) {
        self.purchased = IAPStoreManager.shared.purchased
        if tableView.window != nil { tableView.reloadData() }
        delegate?.didPurchase(productIdentifier: transaction.payment.productIdentifier)
    }
    
    /// Handles failed of the transaction.
    ///
    public func failed(_ transaction: SKPaymentTransaction) {
        hideLoading()
        hideLoadingPurchases()
        presentAlert(
            title: NSLocalizedString("IAPViewController.PaymentTransactionError.Title", comment: ""),
            message: NSLocalizedString("IAPViewController.PaymentTransactionError.Message", comment: ""),
            error: transaction.error
        )
    }
    
    /// Handles failed cancelation of the transaction.
    ///
    public func canceled(_ transaction: SKPaymentTransaction) {
        enableUserInterface()
        
        // deselect any selected row
        guard tableView.window != nil else { return }
        tableView.indexPathsForSelectedRows?.forEach({ tableView.deselectRow(at: $0, animated: true) })
        tableView.reloadSections(IndexSet(integer: Sections.available), with: .none)
    }
    
    // MARK: - Restore
    
    public func restoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        hideLoadingPurchases()
    }
    
    public func restoreCompletedTransactionsFailedWithError(_ error: SKError?) {
        hideLoadingPurchases()
        presentAlert(
            title: NSLocalizedString("IAPViewController.RestoreError.Title", comment: ""),
            message: NSLocalizedString("IAPViewController.RestoreError.Message", comment: ""),
            error: error
        )
    }
    
    public func restoreCompletedTransactionsCanceled(_ error: SKError) {
        hideLoadingPurchases()
    }
}
