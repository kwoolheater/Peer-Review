//
//  DetailViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 11/30/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Firebase
import FirebaseDatabase

class DetailViewController: UIViewController {
    
    // declare variables
    var email: String?
    var uid: String?
    var ref: DatabaseReference!
    
    // declare outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set name label
        configureDatabase()
        nameLabel.text = email
        addTextViewBorder()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        
    }
    
    func addTextViewBorder() {
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @IBAction func pushRating(_ sender: Any) {
        if textView.text == nil {
            self.ref.child("users").child(uid!).child("reviews").childByAutoId().setValue(["stars": starView.rating,
                                                                                           "poster": SavedItems.sharedInstance().user?.email])
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.ref.child("users").child(uid!).child("reviews").childByAutoId().setValue(["stars": starView.rating,
                                                                                           "poster": SavedItems.sharedInstance().user?.email,
                                                                                           "message": textView.text])
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
