//
//  InAppPurchasesViewController + Delegate.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import UIKit
import StoreKit

public extension IAPViewController {
    
    /// Starts a purchase when the user taps an available product row.
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isUserInterfaceEnabled else { return }
        guard !isLoading else { return }
        
        switch indexPath.section {
        case Sections.available:
            buy(indexPath: indexPath)
        case Sections.purchased:
            presentPaymentTransactionDetails(indexPath: indexPath)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func buy(indexPath: IndexPath) {
        let product = availableProducts[indexPath.row]
        if IAPStoreManager.shared.isPurchased(product: product) { return }
        disableUserInterface()
        tableView.cellForRow(at: indexPath)?.isLoading = true
        IAPStoreManager.shared.buy(product)
    }
    
    private func presentPaymentTransactionDetails(indexPath: IndexPath) {
        
        let paymentTransaction = self.purchased[indexPath.row]
        
        let transactionDetails = UIStoryboard(name: "InAppPurchases", bundle: Bundle.module)
            .instantiateViewController(withIdentifier: "IAPPaymentTransactionDetailsViewController") as! IAPPaymentTransactionDetailsViewController
        
        var data: [IAPPaymentTransactionDetailsViewController.Key: String?] = [:]
        
        data[.productIdentifier] = IAPStoreManager.shared.title(matchingPaymentTransaction: paymentTransaction)
        data[.transactionIdentifier] = paymentTransaction.transactionIdentifier
        data[.transactionDate] = self.dateFormatter.string(from: paymentTransaction.transactionDate!)
        
        let allDownloads = paymentTransaction.downloads
        
        if let firstDownload = allDownloads.first {
            data[.contentIdentifier] = firstDownload.contentIdentifier
            data[.contentVersion] = firstDownload.contentIdentifier
            data[.contentLength] = firstDownload.downloadContentSize
        }
        
        if let transactionIdentifier = paymentTransaction.original?.transactionIdentifier {
            data[.originalTransaction] = transactionIdentifier
        }
        
        if let date = paymentTransaction.original?.transactionDate {
            data[.originalTransactionDate] = self.dateFormatter.string(from: date)
        }
        
        transactionDetails.data = data
        transactionDetails.title = IAPStoreManager.shared.title(matchingPaymentTransaction: paymentTransaction)
        
        present(transactionDetails, animated: true)
    }
}
