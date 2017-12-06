//
//  ViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 11/20/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import FirebaseAuthUI

class ViewController: UIViewController {

    // initialize outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var starView: CosmosView!
    
    // declare variables
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    var ref: DatabaseReference!
    var userUid: String?
    var messageArray: [String] = []
    var ratingsArray: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        starView.rating = 0
        ratingLabel.text = "No current rating"
        usernameLabel.text = displayName
    }
    
    func configureAuth() {
        // listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
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
                self.loginSession()
            }
        }
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for (_ , user) in value! {
                let newUser = user as? NSDictionary
                let email = newUser?["email"] as? String
                if email == self.user?.email {
                    self.userUid = newUser?["uid"] as? String
                    self.getRatings()
                }
            }
        })
    }
    
    func getRatings() {
        ref.child("users").child(userUid!).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            let response = snapshot.value as? NSDictionary
            
            for (key, value) in response! {
                let postInfo = value as? NSDictionary
                let rating = postInfo!["stars"] as? Double
                let message = postInfo!["message"] as? String
                
                self.ratingsArray.append(rating!)
                if message != nil {
                    self.messageArray.append(message!)
                }
            }
            
            var count = 0.0
            var sum = 0.0
            for value in self.ratingsArray {
                sum = sum + value
                count = count + 1.0
            }
            
            let overallRating = sum/count
            
            self.starView.rating = (overallRating)
            self.ratingLabel.text = "\(overallRating)"
        })
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    func signedInStatus(isSignedIn: Bool) {
        if isSignedIn {
        }
    }
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }

}
