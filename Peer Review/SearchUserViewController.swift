//
//  SearchUserViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 11/23/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseDatabase

class SearchUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // declare outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var authButton: UIBarButtonItem!
    
    // declare variables
    var ref: DatabaseReference!
    var namesArray: [String]! = []
    var uidArray: [String]! = []
    var sentUid: String?
    var sentEmail: String?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNamesArray = [String]()
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(self.refreshControl)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user emails"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        configureDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if SavedItems.sharedInstance().signedIn == false {
            self.authButton.title = "Sign In"
            configureAuth()
        } 
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        // get data from children
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for (_ , user) in value! {
                let newUser = user as? NSDictionary
                let email = newUser?["email"] as? String
                let uid = newUser?["uid"] as? String
                self.namesArray?.append(email!)
                self.uidArray?.append(uid!)
                self.tableView.reloadData()
            }
        })
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
                    SavedItems.sharedInstance().user = self.user
                }
            } else {
                // user must sign in
                self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    func signedInStatus(isSignedIn: Bool) {
        SavedItems.sharedInstance().signedIn = isSignedIn
        
        if isSignedIn {
            signedIn()
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
            namesArray.removeAll()
            uidArray.removeAll()
            tableView.reloadData()
            signedInStatus(isSignedIn: false)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let email: String
        if isFiltering() {
            email = filteredNamesArray[indexPath.row]
        } else {
            email = namesArray[indexPath.row]
        }
        cell.textLabel?.text = email
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredNamesArray.count
        }
        
        return namesArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sentEmail = namesArray[indexPath.row]
        sentUid = uidArray[indexPath.row]
        
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let segue = segue.destination as! DetailViewController
            segue.uid = sentUid
            segue.email = sentEmail
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredNamesArray = namesArray.filter({( name : String) -> Bool in
            return name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.namesArray.removeAll()
        self.uidArray.removeAll()
        configureDatabase()
        refreshControl.endRefreshing()
    }
    
}

extension SearchUserViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
