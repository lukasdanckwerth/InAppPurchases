//
//  SKDownload + Extension.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 16.03.22.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import Foundation
import StoreKit

extension SKDownload {
    
    /// - returns: A string representation of the downloadable content length.
    ///
    var downloadContentSize: String {
        if #available(iOS 13.0, *) {
            return ByteCountFormatter.string(fromByteCount: self.expectedContentLength, countStyle: .file)
        } else {
            return "IAPPaymentTransactionDetailsViewController.Unknown"
        }
    }
}
