//
//  StoreManager.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import StoreKit
import Foundation

fileprivate let userDefaultsKey = "de.aid.InAppPurchases.PurchasedProductIdentifiersList"

fileprivate func loadFromUserDefaults() -> Set<String> {
    return Set(UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? [])
}

fileprivate func storeToUserDefaults(identifiers: Set<String>) {
    UserDefaults.standard.set(Array<String>(identifiers), forKey: userDefaultsKey)
}

/// Manages purchases from the App Store.
///
public class IAPStoreManager: NSObject {
    
    // MARK: - Shared Instance
    
    /// The default shared instance.
    ///
    public static let shared = IAPStoreManager()
    
    // MARK: - Properties
    
    /// Keeps track of all valid products. These products are available for sale in the App Store.
    ///
    public internal(set) var availableProducts: [SKProduct] = []
    
    /// Keeps track of all invalid product identifiers.
    ///
    public internal(set) var invalidProductIdentifiers = [String]()
    
    /// Keeps track of all purchases.
    ///
    public internal(set) var purchased: [SKPaymentTransaction] = []
    
    /// The object that acts as a delegate for the receiver.
    ///
    public weak var delegate: StoreManagerDelegate?
    
    /// Holds the collection of product identifiers purchased on this device
    ///
    public private(set) var purchasedProductIdentifiers = loadFromUserDefaults()
    
    /// Keeps a strong reference to the products request.
    ///
    internal var productRequest: SKProductsRequest!
    
    
    // MARK: - Initializer
    
    private override init() {}
    
    
    // MARK: - Request Product Information
    
    /// Starts the product request with the specified identifiers.
    ///
    func startProductRequest(with identifiers: [String]) {
        let productIdentifiers = Set(identifiers)
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
    }
    
    // MARK: - Helper Methods
    
    /// - returns: Existing product's title matching the specified product identifier.
    ///
    func title(matchingIdentifier identifier: String) -> String? {
        return availableProducts
            .filter({ (product: SKProduct) in product.productIdentifier == identifier })
            .first?
            .localizedTitle
    }
    
    /// - returns: Existing product's title associated with the specified payment transaction.
    ///
    func title(matchingPaymentTransaction transaction: SKPaymentTransaction) -> String {
        return self.title(matchingIdentifier: transaction.payment.productIdentifier)
        ?? transaction.payment.productIdentifier
    }
    
    func addLocal(purchasedProductIdentifier identifier: String) {
        purchasedProductIdentifiers.insert(identifier)
        storeToUserDefaults(identifiers: purchasedProductIdentifiers)
    }
    
    /// - returns: Whether the specified product is purchased.
    ///
    public func isPurchased(product: SKProduct) -> Bool {
        return isPurchased(productIdentifier: product.productIdentifier)
    }
    
    /// - returns: Whether the specified product identifier is purchased.
    ///
    public func isPurchased(productIdentifier: String) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
}
