//
//  ViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 11/20/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import Cosmos

class ViewController: UIViewController {

    // initialize outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var starView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starView.rating = 4
        ratingLabel.text = "4"
        usernameLabel.text = "Kiyoshi Woolheater"
        
    }
    
}

