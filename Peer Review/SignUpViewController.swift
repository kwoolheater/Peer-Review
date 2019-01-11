//
//  SignUpViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 4/1/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var nameField: TextField!
    @IBOutlet weak var companyField: TextField!
    @IBOutlet weak var passField: TextField!
    
    var currentTextField:String = ""
    var ref: DatabaseReference!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        companyField.layer.borderColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0).cgColor
        passField.layer.borderColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0).cgColor
        emailField.layer.borderColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0).cgColor
        nameField.layer.borderColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0).cgColor
        companyField.layer.borderWidth = 2
        passField.layer.borderWidth = 2
        emailField.layer.borderWidth = 2
        nameField.layer.borderWidth = 2
        UITextField.appearance().tintColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0)
        passField.delegate = self
        companyField.delegate = self
        emailField.delegate = self
        nameField.delegate = self
    }
    
    @IBAction func signUp(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailField.text!, password: passField.text!) { (user, error) in
            if error == nil {
                self.user = user
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameField.text!
                changeRequest?.commitChanges { (error) in
                    if (error != nil) {
                        self.showError(error: (error?.localizedDescription)!)
                    } else {
                        SavedItems.sharedInstance().user = user!
                        SavedItems.sharedInstance().signedIn = true
                        self.saveUserToDb()
                        self.performSegue(withIdentifier: "signIn", sender: self)
                        self.emailField.text = ""
                        self.nameField.text = ""
                        self.companyField.text = ""
                        self.passField.text = ""
                    }
                }
            } else {
                self.showError(error: (error?.localizedDescription)!)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveUserToDb() {
        ref = Database.database().reference()
        ref.child("users").child(user?.uid as! String).setValue(["email": user?.email as! String, "uid": user?.uid as! String])
    }
    @objc func keyboardWillShow(_ notification:Notification) {
        // raises keyboard if bottom text field is selected
        if currentTextField == "passField" || currentTextField == "companyField" {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passField {
            currentTextField = "passField"
        } else if textField == companyField {
            currentTextField = "passField"
        } else {
            currentTextField = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showError(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

