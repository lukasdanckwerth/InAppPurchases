//
//  InAppPurchasesViewControllerDelegate.swift
//  InAppPurchases
//
//  Created by Lukas Danckwerth on 13.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import UIKit

@objc public protocol IAPViewControllerDelegate: AnyObject {
    func didPurchase(productIdentifier: String)
    
    @objc optional func viewDidAppear()
    
    @objc optional func viewDidDisappear()
}
