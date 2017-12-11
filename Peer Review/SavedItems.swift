//
//  SavedItems.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 12/5/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import Firebase

class SavedItems: NSObject {
    
    // Save user
    var user: User?
    var signedIn: Bool?
    
    // create a shared instance
    class func sharedInstance() -> SavedItems {
        struct Singleton {
            static var sharedInstance = SavedItems()
        }
        return Singleton.sharedInstance
    }
}
