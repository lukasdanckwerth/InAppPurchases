//
//  IAPViewController + DataSource.swift
//  Rima
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import UIKit
import StoreKit

public extension IAPViewController {
    
    struct Sections {
        static let info = 0
        static let available = 1
        static let purchased = 2
        static let invalid = 3
    }
    
    // MARK: - UITable​View​Data​Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLoading ? 1 : 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isLoading else { return nil }
        
        switch section {
        case Sections.info:
            return NSLocalizedString("IAPViewController.Section.Title.Info", comment: "")
        case Sections.available where !availableProducts.isEmpty:
            return NSLocalizedString("IAPViewController.Section.Title.Available", comment: "")
        case Sections.purchased where !purchased.isEmpty || isLoadingPurchases:
            return NSLocalizedString("IAPViewController.Section.Title.Purchased", comment: "")
        case Sections.invalid where showInvalidIdentifier && !invalidIdentifiers.isEmpty:
            return NSLocalizedString("IAPViewController.Section.Title.Invalid", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard !isLoading else { return nil }
        guard section == Sections.purchased else { return nil }
        guard purchased.isEmpty else { return nil }
        
        return NSLocalizedString("IAPViewController.Text.RestorePurchased", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isLoading else { return 1 }
        switch section {
        case Sections.info:
            return 1
        case Sections.available:
            return availableProducts.count
        case Sections.purchased:
            return isLoadingPurchases ? 1 : purchased.count
        case Sections.invalid where showInvalidIdentifier:
            return invalidIdentifiers.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !isLoading else { return loadingCell(indexPath: indexPath) }
        
        switch indexPath.section {
        case Sections.info:
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.info, for: indexPath)
        case Sections.available:
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.availableProduct, for: indexPath)
        case Sections.purchased where isLoadingPurchases:
            return loadingCell(indexPath: indexPath)
        case Sections.purchased:
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.purchase, for: indexPath)
        case Sections.invalid:
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.invalidIdentifier, for: indexPath)
        default:
            fatalError("invalid section")
        }
    }
    
    func loadingCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loading, for: indexPath)
        cell.activityIndicatorView?.tintColor = self.view.tintColor
        cell.activityIndicatorView?.color = self.view.tintColor
        cell.activityIndicatorView?.startAnimating()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isLoading else { return }
        
        switch indexPath.section {
        case Sections.info:
            cell.textLabel!.text = NSLocalizedString("IAPViewController.Text.Info", comment: "").trimmingCharacters(in: .whitespacesAndNewlines)
            
        case Sections.available:
            
            let product = availableProducts[indexPath.row]
            cell.textLabel!.text = product.localizedTitle
            cell.detailTextLabel?.textColor = self.view.tintColor
            
            if IAPStoreManager.shared.isPurchased(product: product) {
                
                cell.detailTextLabel?.text = NSLocalizedString("IAPViewController.Label.Purchased", comment: "")
                cell.accessoryType = .checkmark
                cell.tintColor = self.view.tintColor
                
            } else if let formattedPrice = product.regularPrice {
                cell.detailTextLabel?.text = "\(formattedPrice)"
            }
            
            cell.isLoading = false
            
        case Sections.purchased where !isLoadingPurchases:
            let transaction = purchased[indexPath.row]
            let productIdentifier = transaction.payment.productIdentifier
            cell.textLabel?.text = IAPStoreManager.shared.title(matchingIdentifier: productIdentifier) ?? productIdentifier
            
        case Sections.purchased where isLoadingPurchases:
            cell.activityIndicatorView?.startAnimating()
            
        case Sections.invalid:
            cell.textLabel!.text = invalidIdentifiers[indexPath.row]
            
        default: break
        }
    }
}



// MARK: - SKProduct

extension SKProduct {
    
    /// - returns: The cost of the product formatted in the local currency.
    ///
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}
