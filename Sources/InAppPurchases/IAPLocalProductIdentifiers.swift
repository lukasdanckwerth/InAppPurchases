//
//  IAPLocalProductIdentifiers.swift
//  Rima
//
//  Created by Lukas Danckwerth on 10.01.21.
//  Copyright © 2021 Lukas Danckwerth. All rights reserved.
//

import Foundation

/// A structure that specifies the name and file extension of a resource file, which contains the product identifiers to be queried.
///
public struct IAPLocalProductIdentifiers {
    
    /// Name of the resource file containing the product identifiers.
    ///
#if DEBUG
    static let name = "ProductIdsDev"
#else
    static let name = "ProductIds"
#endif
    
    /// Filename extension of the resource file containing the product identifiers.
    ///
    static let fileExtension = "plist"
    
    /// The path of the resource file.
    ///
    static var path: String? {
        return Bundle.main.path(forResource: name, ofType: fileExtension)
    }
    
    /// - returns: An array with the product identifiers to be queried.
    ///
    public static var identifiers: [String]? {
        if let p = IAPLocalProductIdentifiers.path {
            return NSArray(contentsOfFile: p) as? [String]
        } else {
            return []
        }
    }
}
