//
//  ViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 11/20/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Firebase
import FirebaseAuthUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // initialize outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var authButton: UIBarButtonItem!
    
    // declare variables
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _refHandle: DatabaseHandle!
    var user: User?
    var displayName = "Anonymous"
    var ref: DatabaseReference!
    var userUid: String?
    var messageArray: [String] = []
    var ratingsArray: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        starView.rating = 0
        ratingLabel.text = "No current rating"
        usernameLabel.text = displayName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(self.refreshControl)
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
                    // self.addReference()
                }
            }
        })
    }
    
    func getRatings() {
        ref.child("users").child(userUid!).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let response = snapshot.value as? NSDictionary else {
                print("No reviews.")
                return
            }
            
            for (_, value) in response {
                let postInfo = value as? NSDictionary
                let rating = postInfo!["stars"] as? Double
                let message = postInfo!["message"] as? String
                
                self.ratingsArray.append(rating!)
                if message != "" {
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
            let roundedRating = String(format: "%.2f", overallRating)
            
            self.starView.rating = (overallRating)
            self.ratingLabel.text = "\(roundedRating)"
            
            self.tableView.reloadData()
        })
    }
    
    /* func addReference() {
        _refHandle = ref.child("users").child(userUid!).child("reviews").observe(.childAdded) { (snapshot: DataSnapshot) in
            self.configureDatabase()
        }
    } */
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
        ref.child("users").child(userUid!).child("reviews").removeObserver(withHandle: _refHandle)
    }
    
    func signedInStatus(isSignedIn: Bool) {
        SavedItems.sharedInstance().signedIn = isSignedIn
        
        if isSignedIn {
            signedIn()
            configureDatabase()
        } else {
            signedOut()
        }
    }
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
    
    func signedIn() {
        authButton.title = "Sign Out"
    }
    
    func signedOut() {
        authButton.title = "Sign In"
    }
    
    @IBAction func authButton(_ sender: Any) {
        
        if SavedItems.sharedInstance().signedIn == false {
            configureAuth()
        } else {
            do {
                try Auth.auth().signOut()
            } catch {
                print("error signing out")
            }
            // clear tableview
            // self.tableView.
            signedInStatus(isSignedIn: false)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messageArray == nil {
            return 0
        } else {
            return messageArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let message = messageArray[indexPath.row]
        cell.textLabel?.text = message
        return cell
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        configureDatabase()
        refreshControl.endRefreshing()
    }
}
