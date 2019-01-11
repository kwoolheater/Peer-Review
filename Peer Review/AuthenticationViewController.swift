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
    
    @IBOutlet weak var usernameField: TextField!
    @IBOutlet weak var passField: TextField!
    @IBOutlet var orLabel: UILabel!
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.layer.borderColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0).cgColor
        passField.layer.borderColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0).cgColor
        usernameField.layer.borderWidth = 2
        passField.layer.borderWidth = 2
        UITextField.appearance().tintColor = UIColor(red:1.00, green:0.82, blue:0.33, alpha:1.0)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthenticationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func signIn(_ sender: Any) {
        if usernameField.text != nil || passField.text != nil {
            self.orLabel.isHidden = true
            showActivityIndicatory(uiView: self.view, startAnimate: true)
            Auth.auth().signIn(withEmail: usernameField.text!, password: passField.text!) { (user, error) in
                if error == nil {
                    SavedItems.sharedInstance().user = user!
                    SavedItems.sharedInstance().signedIn = true
                    self.performSegue(withIdentifier: "signIn", sender: self)
                    self.showActivityIndicatory(uiView: self.view, startAnimate: false)
                    self.usernameField.text = ""
                    self.passField.text = ""
                    self.orLabel.isHidden = false
                } else {
                    self.showError(error: (error?.localizedDescription)!)
                }
            }
        } else if usernameField == nil {
            usernameField.layer.borderColor = UIColor.red.cgColor
        } else if passField == nil {
            passField.layer.borderColor = UIColor.red.cgColor
        } else {
            
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
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
    
    func showActivityIndicatory(uiView: UIView, startAnimate: Bool) {
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.center = orLabel.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        uiView.addSubview(actInd)
        if startAnimate {
            self.actInd.startAnimating()
        } else {
            self.actInd.stopAnimating()
        }
    }
    
    /*func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == "signIn" {
            
        }
    }*/
}

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
