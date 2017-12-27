//
//  LoginViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 12/20/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuthUI

class LoginViewController: UIViewController {
    
    fileprivate var _authHandle: AuthStateDidChangeListenerBlock!
    var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signIn(_ sender: Any) {
        self.configureAuth()
    }
    
    func configureAuth() {
        _authHandle = Auth.auth().addStateDidChangeListener{ (auth: Auth, user: User?) in
            // check if there is a current user
            if let activeUser = user {
                // check if the current app user is the current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.usernameLabel.text = self.user?.displayName
                    SavedItems.sharedInstance().user = self.user
                }
            } else {
                // user must sign in
                self.signedInStatus(isSignedIn: false)
                let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
                present(authViewController, animated: true, completion: nil)
            }
        }
    }
    
    func signedInStatus(isSignedIn: Bool) {
        if isSignedIn {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        <#code#>
//    }
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
}
