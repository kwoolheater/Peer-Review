//
//  ProfileViewController.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 1/4/19.
//  Copyright © 2019 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

class ProfileTableViewController: UITableViewController {
    
    // initialize outlets
    //@IBOutlet weak var usernameLabel: UILabel!
    //@IBOutlet weak var ratingLabel: UILabel!
    //@IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    // declare variables
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _refHandle: DatabaseHandle!
    var user: User?
    var displayName = "Anonymous"
    var ref: DatabaseReference!
    var userUid: String?
    var messageArray: [String] = []
    var ratingsArray: [Double] = []
    var ratingArray = [[String: Any]]()
    var userRating = ""
    var doubleRating = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuth()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProfileTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(self.refreshControl!)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.layoutSubviews()
    }
    
    func checkAuth() {
        user = SavedItems.sharedInstance().user
        signedInStatus(isSignedIn: true)
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for (_ , user) in value! {
                let newUser = user as? NSDictionary
                let email = newUser?["email"] as? String
                if email == self.user?.email {
                    self.userUid = newUser?["uid"] as? String
                    self.getRatings()
                }
            }
        })
    }
    
    func getRatings() {
        ref.child("users").child(userUid!).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let response = snapshot.value as? NSDictionary else {
                print("No reviews.")
                return
            }
            
            for (_, value) in response {
                let postInfo = value as? NSDictionary
                let rating = postInfo!["stars"] as? Double
                let message = postInfo!["message"] as? String
                
                self.ratingsArray.append(rating!)
                if message != "" {
                    self.messageArray.append(message!)
                    self.ratingArray.append(["rating": rating!, "message": message!])
                } else {
                    self.ratingArray.append(["rating": rating!, "message": ""])
                }
            }
            
            self.ratingArray.append(["rating": 4.0, "message": "Thought I scored you a 4 I am truly disappionted in your preformance this year. I expected much more from you as an employee"])
            
            var count = 0.0
            var sum = 0.0
            for value in self.ratingsArray {
                sum = sum + value
                count = count + 1.0
            }
            
            let overallRating = sum/count
            let roundedRating = String(format: "%.2f", overallRating)
            
            self.userRating = roundedRating
            self.doubleRating = overallRating
            
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.rowHeight = UITableViewAutomaticDimension
            
            self.tableView.reloadData()
        })
    }
    
    func signedInStatus(isSignedIn: Bool) {
        SavedItems.sharedInstance().signedIn = isSignedIn
        
        if isSignedIn {
            signedIn()
            configureDatabase()
        } else {
            signedOut()
        }
    }
    
    func signedIn() {
        signOutButton.title = "Sign Out"
    }
    
    func signedOut() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func authButton(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("error signing out")
        }
        // clear tableview
        self.messageArray.removeAll()
        self.ratingsArray.removeAll()
        self.ratingArray.removeAll()
        self.tableView.reloadData()
        signedInStatus(isSignedIn: false)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            /*if messageArray == nil || messageArray.count == 0 {
                return 1
            } else {
                return messageArray.count
            }*/
            if ratingArray == nil || ratingArray.count == 0 {
                return 1
            } else {
                return ratingArray.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! ProfileTableViewCell
            cell.nameLabel.text = self.user?.displayName
            if userRating != "" {
                cell.ratingLabel.text = "Quarter Reviews: \(userRating)"
            }
            cell.starView.rating = doubleRating
            return cell
        } else {
            if ratingArray.count != 0 {
                let rating = ratingArray[indexPath.row]
                var message = ""
                var stars = 0.0
                for (key, value) in rating {
                    if key == "message" {
                        message = value as! String
                    } else {
                        stars = value as! Double
                    }
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableViewCell
                cell.starNumberLabel.text = String(Int(stars))
                if message != nil {
                    cell.ratingDescriptionLabel.text = message
                } else {
                    cell.ratingDescriptionLabel.isHidden = true
                    cell.dividerView.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! UITableViewCell
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView()
            headerView.backgroundColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1.0)
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 10, width: tableView.bounds.size.width, height: 27.0))
            headerLabel.textColor = UIColor.white
            headerLabel.text = "Explanations"
            headerLabel.font = UIFont.systemFont(ofSize: 27.0)
            headerLabel.textAlignment = .center
            headerView.addSubview(headerLabel)
            return headerView
        } else {
            let headerView = UIView()
            headerView.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
            return headerView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        } else {
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView()
            footerView.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
            return footerView
        } else {
            return UIView(frame: .zero)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.messageArray.removeAll()
        self.ratingsArray.removeAll()
        self.ratingArray.removeAll()
        getRatings()
        refreshControl.endRefreshing()
    }
}

extension UIView {
    func roundCorners(cornerRadius: Double) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
