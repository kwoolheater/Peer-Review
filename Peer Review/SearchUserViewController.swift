//
//  SearchUserViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 11/23/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import Firebase

class SearchUserViewController: UIViewController {
    
    // declare outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // declare variables
    var ref: DatabaseReference!
    var dataArray: [DataSnapshot]! = []
    var namesArray: [String]?
    fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView.delegate = self
        // tableView.dataSource = self
        // searchBar.delegate = self
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
                namesArray?.append(email!)
            }
        })
    }
    
}
