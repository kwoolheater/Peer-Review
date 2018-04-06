//
//  SignUpViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 4/1/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var companyField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUp(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailField.text!, password: passField.text!) { (user, error) in
            print(user)
            print(error?.localizedDescription)
        }
    }
    
}
