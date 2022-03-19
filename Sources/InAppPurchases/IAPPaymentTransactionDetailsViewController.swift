//
//  IAPPaymentTransactionDetailsViewController.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import UIKit
import StoreKit

public class IAPPaymentTransactionDetailsViewController: UITableViewController {
    
    enum Key: String {
        case contentIdentifier = "Identifier"
        case contentVersion = "Version"
        case contentLength = "Length"
        case transactionDate = "TransactionDate"
        case transactionIdentifier = "TransactionID"
        case originalTransactionDate = "OriginalTransactionDate"
        case originalTransactionIdentifier = "OriginalTransactionID"
        case originalTransaction = "OriginalTransaction"
        case productIdentifier = "ProductIdentifier"
        
        var localized: String {
            return NSLocalizedString("IAPPaymentTransactionDetailsViewController.\(rawValue)", comment: "")
        }
    }
    
    struct Sections {
        static let transaction = 0
        static let downloads = 1
        static let originalTransaction = 2
    }
    
    struct CellIdentifiers {
        static let row = "row"
    }
    
    var data: [Key: String?] = [:]
    
    // MARK: - UITable​View​Data​Source
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.transaction:
            return 3
        case Sections.downloads:
            return 3
        case Sections.originalTransaction:
            return 2
        default:
            return 0
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.row, for: indexPath)
        
        var key: Key?
        switch indexPath.section {
        case Sections.transaction where indexPath.row == 0:
            key = .productIdentifier
        case Sections.transaction where indexPath.row == 1:
            key = .transactionIdentifier
        case Sections.transaction where indexPath.row == 2:
            key = .transactionDate
        case Sections.downloads where indexPath.row == 0:
            key = .contentIdentifier
        case Sections.downloads where indexPath.row == 1:
            key = .contentVersion
        case Sections.downloads where indexPath.row == 2:
            key = .contentLength
        case Sections.originalTransaction where indexPath.row == 0:
            key = .originalTransaction
        case Sections.originalTransaction where indexPath.row == 1:
            key = .originalTransactionIdentifier
        case Sections.originalTransaction where indexPath.row == 2:
            key = .originalTransactionDate
        default:
            break
        }
        
        if let strongKey = key {
            cell.textLabel?.text = strongKey.localized
            cell.detailTextLabel?.text = data[strongKey] ?? "-"
        }
        
        return cell
    }
}
