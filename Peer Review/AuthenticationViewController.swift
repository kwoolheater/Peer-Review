//
//  AuthenticationViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 3/31/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticationViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signIn(_ sender: Any) {
        if usernameField.text != nil && passField.text != nil {
            Auth.auth().signIn(withEmail: usernameField.text!, password: passField.text!) { (user, error) in
                if error == nil {
                    SavedItems.sharedInstance().user = user!
                    SavedItems.sharedInstance().signedIn = true
                    self.performSegue(withIdentifier: "signIn", sender: self)
                } else {
                    print(error?.localizedDescription as! String)
                }
            }
        } else {
            
        }
    }
}
