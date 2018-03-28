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
import FirebaseDatabase

class SearchUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // declare outlets
    @IBOutlet weak var tableView: UITableView!
    
    // declare variables
    var ref: DatabaseReference!
    var namesArray: [String]! = []
    var uidArray: [String]! = []
    var sentUid: String?
    var sentEmail: String?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNamesArray = [String]()
    var user: User?
    private let image = UIImage(named: "profile-big")!.withRenderingMode(.alwaysTemplate)
    private let topMessage = "Login"
    private let bottomMessage = "You need to login to access the evaluation system. Return to the Profile screen."
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureUI()
        if SavedItems.sharedInstance().signedIn == true {
            configureDatabase()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        namesArray.removeAll()
        uidArray.removeAll()
        tableView.reloadData()
    }
    
    func configureUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(self.refreshControl)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user emails"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        let emptyBackgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
        tableView.backgroundView = emptyBackgroundView
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
                if email != SavedItems.sharedInstance().user?.email {
                    self.namesArray?.append(email!)
                    self.uidArray?.append(uid!)
                    self.tableView.reloadData()
                }
            }
        })
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
        if namesArray.count == 0 {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        
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
