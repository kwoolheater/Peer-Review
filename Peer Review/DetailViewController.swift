//
//  DetailViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 11/30/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Cosmos

class DetailViewController: UIViewController {
    
    // declare variables
    var email: String?
    var uid: String?
    var ref: DatabaseReference!
    
    // declare outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set name label
        configureDatabase()
        nameLabel.text = email
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    @IBAction func pushRating(_ sender: Any) {
        print(starView.rating)
        self.ref.child("users").child(uid!).child("reviews").setValue(["stars": starView.rating])
    }
    
    
}
