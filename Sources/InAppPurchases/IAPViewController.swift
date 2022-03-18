//
//  IAPViewController.swift
//  IAPViewController
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import UIKit
import StoreKit

public class IAPViewController: UITableViewController {
    
    // MARK: - Static
    
    public static func createInAppPurchasesViewController() -> IAPViewController {
        return UIStoryboard(name: "InAppPurchases", bundle: Bundle.module)
            .instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
    }
    
    // MARK: - Types
    
    struct CellIdentifiers {
        static let availableProduct = "available"
        static let purchase = "purchase"
        static let invalidIdentifier = "invalid"
        static let loading = "loading"
        static let info = "info"
    }
    
    // MARK: - Private Properties
    
    /// A Boolean value indicating whether the row for loading is presented.
    ///
    internal private(set) var isLoading: Bool = true
    
    /// A Boolean value indicating whether the row for loading purchases is presented.
    ///
    internal private(set) var isLoadingPurchases: Bool = false
    
    /// A Boolean value indicating whether the user can selcect rows or buttons.  Used
    /// when the purchase dialog of Apple is presented to disable the view.
    ///
    internal private(set) var isUserInterfaceEnabled: Bool = true
    
    
    
    // MARK: - Public Properties / Configuration
    
    open lazy var dismissBarButtonItem: UIBarButtonItem? = UIBarButtonItem(
        title: NSLocalizedString("IAPViewController.Button.Dismiss", comment: ""),
        style: .plain,
        target: self,
        action: #selector(dismissBarButtonAction)
    )
    
    open lazy var restoreBarButtonItem: UIBarButtonItem? = UIBarButtonItem(
        title: NSLocalizedString("IAPViewController.Button.Restore", comment: ""),
        style: .plain,
        target: self,
        action: #selector(restore)
    )
    
    /// The object that acts as a delegate for the `IAPViewController`.
    ///
    public weak var delegate: IAPViewControllerDelegate?
    
    /// The date formatter used to format dates displayed in the `IAPPaymentTransactionDetailsViewController`.
    ///
    public var dateFormatter: DateFormatter = DateFormatter()
    
    /// Wheather to show invalid identifiers found in the local plist file but not known by App Store.
    /// Default is `true` for DEBUG and `false` for RELEASE
    ///
#if DEBUG
    public var showInvalidIdentifier = true
#else
    public var showInvalidIdentifier = false
#endif
    
    /// Indentifiers loaded from local file but are not known by app store.
    ///
    public internal(set) var invalidIdentifiers: [String] = []
    
    /// Holds the collection of available products.
    ///
    public internal(set) var availableProducts: [SKProduct] = []
    
    /// Holds the collection of purchased transaction.
    ///
    public internal(set) var purchased: [SKPaymentTransaction] = []
    
    
    // MARK: - View Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.restoreBarButtonItem?.isEnabled = false
        self.navigationItem.title = NSLocalizedString("IAPViewController.Title", comment: "")
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let dismissBarButtonItem = self.dismissBarButtonItem {
            self.navigationItem.leftBarButtonItem = dismissBarButtonItem
        }
        
        if let restoreBarButtonItem = self.restoreBarButtonItem {
            self.navigationItem.rightBarButtonItem = restoreBarButtonItem
        }
        
        IAPStoreManager.shared.delegate = self
        self.fetchProductInformation()
        delegate?.viewDidAppear?()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard navigationController?.isBeingDismissed == true else { return }
        delegate?.viewDidDisappear?()
        IAPStoreManager.shared.delegate = nil
    }
    
    
    // MARK: - Fetch Product Information
    
    /// Retrieves product information from the App Store.
    fileprivate func fetchProductInformation() {
        
        self.purchased = IAPStoreManager.shared.purchased
        
        guard IAPStoreManager.shared.isAuthorizedForPayments else {
            presentAlert(
                title: NSLocalizedString("IAPViewController.NotAuthorizedForPayments.Title", comment: ""),
                message: NSLocalizedString("IAPViewController.NotAuthorizedForPayments.Message", comment: "")
            )
            return
        }
        
        guard let identifiers = IAPLocalProductIdentifiers.identifiers, !identifiers.isEmpty else {
            presentAlert(title: "Status", message: "Resources file not found.")
            return
        }
        
        self.invalidIdentifiers = identifiers
        self.tableView.reloadData()
        
        IAPStoreManager.shared.startProductRequest(with: identifiers)
    }
    
    
    
    // MARK: - Restore All Appropriate Purchases
    
    /// Called when tapping the "Restore" button in the UI.
    ///
    @objc open func restore(_ sender: UIBarButtonItem) {
        showLoadingPurchases()
        IAPStoreManager.shared.restore()
    }
    
    /// Selector for dismissing this view controller.
    @objc open func dismissBarButtonAction(sender: UIBarButtonItem?) {
        self.dismiss(animated: true)
    }
    
    func hideLoading() {
        restoreBarButtonItem?.isEnabled = true
        isLoading = false
        guard tableView.window != nil else { return }
        tableView.reloadData()
    }
    
    func showLoadingPurchases() {
        restoreBarButtonItem?.isEnabled = false
        isLoadingPurchases = true
        guard tableView.window != nil else { return }
        tableView.reloadSections(IndexSet(integer: Sections.purchased), with: .none)
    }
    
    func hideLoadingPurchases() {
        restoreBarButtonItem?.isEnabled = true
        isLoadingPurchases = false
        guard tableView.window != nil else { return }
        let indexSet = IndexSet(arrayLiteral: Sections.available, Sections.purchased)
        tableView.reloadSections(indexSet, with: .automatic)
    }
    
    func enableUserInterface() {
        isUserInterfaceEnabled = true
        restoreBarButtonItem?.isEnabled = true
    }
    
    func disableUserInterface() {
        isUserInterfaceEnabled = false
        restoreBarButtonItem?.isEnabled = false
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let buttonTitle = NSLocalizedString("IAPViewController.Button.OK", comment: "")
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func presentAlert(title: String, message: String, error: Error?) {
#if DEBUG
        presentAlert(title: title, message: "\(message) \(error?.localizedDescription ?? "")")
#else
        presentAlert(title: title, message: message)
#endif
    }
}
