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

class SearchUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // declare outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // declare variables
    var ref: DatabaseReference!
    var namesArray: [String]! = []
    var uidArray: [String]! = []
    var sentUid: String?
    var sentEmail: String?
    fileprivate var _refHandle: DatabaseHandle!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNamesArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user emails"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        configureDatabase()
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
    
    
}

extension SearchUserViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
