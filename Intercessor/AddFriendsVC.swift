//
//  AddNewFriendVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddFriendsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: PaddedTextField!
    @IBOutlet weak var addNewFriendTableView: UITableView!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noFriendsLabel: UILabel!
    
    var allUsers: [(username:String, displayname:String, uid:String)] = []
    var userResults: [(username:String, displayname:String, uid:String)] = []
    
    enum ViewState: Int {
        case addFriend, friendRequest
    }
    var viewState: ViewState = .addFriend {
        didSet {
            addNewFriendTableView.reloadData()
            updateUI()
        }
    }
    
    var menuItems = ["Add Friends", "Friend Requests"]
    var menuView: BTNavigationDropdownMenu!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIStuff
        addNewFriendTableView.tableFooterView = UIView()
        noFriendsLabel.isHidden = false
        searchTextField.leftViewMode = UITextFieldViewMode.always
        searchTextField.leftView = UIImageView(image: UIImage(named: "search"))
        searchTextField.becomeFirstResponder()
        
        setupMenu()

        UserRepo.currentUser.friendRequestsReceived.removeAll()
        // update all Users friendRequestRecieved
        Helper.usersRef.child(UserRepo.currentUser.uid).child("friendRequestsReceived").observe(.childAdded, with: { (snapshot) in

            let friendID: String = snapshot.key
            UserRepo.currentUser.friendRequestsReceived.append(friendID)
            if self.viewState == .friendRequest {
                self.addNewFriendTableView.reloadData()
            }
        })

        
        
        // fetch all the usernames and append to allusers variable
        Helper.usernamesRef.observeSingleEvent(of: .value, with: {
            snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                for (userName, object) in dictionary {
                    if let displayName = object["displayName"] as? String, let UID = object["uid"] as? String {
                        if UID != UserRepo.currentUser.uid {
                            if (!self.isAlreadyFriend(UID)) && (UID != UserRepo.currentUser.uid) && (!UserRepo.currentUser.friendRequestsSent.contains(UID)) {   // if it is already a friend/yourself/or already send a friend request
                                self.allUsers.append((username: userName, displayname: displayName.lowercased(), uid: UID))
                            }
                        }
                    }
                }
            } else {
                print("error fetching usernames")
            }
        })
    }
    
    // MARK: - Dropdown Menu
    func setupMenu() {
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                            containerView: self.navigationController!.view,
                                            title: menuItems[0],
                                            items: menuItems as [AnyObject])
        
        // Cells
        menuView.cellTextLabelFont      = UIFont(name: "Avenir-Book", size: 14)
        menuView.cellTextLabelColor     = UIColor.white
        menuView.cellSeparatorColor     = UIColor.white
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        

        // Title View
        menuView.navigationBarTitleFont = UIFont(name: "Avenir-Book", size: 17.0)
        menuView.menuTitleColor         = UIColor.white
        menuView.arrowPadding           = 13.0

        // Misc
        menuView.animationDuration      = 0.2
        menuView.maskBackgroundOpacity  = 0.4
        
        self.navigationItem.titleView = menuView

        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            if indexPath == 0 {
                self.viewState = .addFriend
            } else {
                self.viewState = .friendRequest
            }
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { self.view.endEditing(true) }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.searchTextField {
            textField.resignFirstResponder()
            // start searching for results
            userResults.removeAll()
            searchAndFind()
            if userResults.count != 0 {
                noFriendsLabel.isHidden = true
            }
            addNewFriendTableView.reloadData()
        }
        return true
    }
    
    func searchAndFind() {
        let searchText: String = searchTextField.text!.lowercased()
        for (username, displayName, uid) in allUsers {
            if displayName.contains(searchText) || username.contains(searchText) {    // if a match is found in displayName/username
                userResults.append((username, displayName, uid))
            }
        }
    }
    
    
    @IBAction func switchButtonTapped(_ sender: AnyObject) {
        let menuTable = menuView.getTable() as! BTTableView
        if viewState == .addFriend {
            menuTable.tableView(menuTable, didSelectRowAt: IndexPath(row: 1, section: 0))
            menuView.rotateArrow()
        } else {
            menuTable.tableView(menuTable, didSelectRowAt: IndexPath(row: 0, section: 0))
            menuView.rotateArrow()
        }
        
        
    }
    func updateUI() {
        if viewState == .addFriend {
            self.menuView.setMenuTitle(menuItems[0])
            self.menuView.layoutSubviews()
            self.tableViewTopConstraint.constant = CGFloat(51.0)
            self.searchTextField.isHidden = false
            self.seperatorView.isHidden = false
        } else {
            self.menuView.setMenuTitle(menuItems[1])
            self.menuView.layoutSubviews()
            self.tableViewTopConstraint.constant = CGFloat(0.0)
            self.searchTextField.isHidden = true
            self.seperatorView.isHidden = true
        }
        self.view.endEditing(true)
    }

    // helper function
    func isAlreadyFriend(_ uid: String) -> Bool {
        for friendID in UserRepo.currentUser.friends {
            if uid == friendID {
                return true
            }
        }
        return false
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        Helper.usersRef.child(UserRepo.currentUser.uid).child("friendRequestsReceived").removeAllObservers()
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    

    
}


extension AddFriendsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewState == .addFriend {
            let foundCount = userResults.count
            if foundCount == 0 {
                noFriendsLabel.isHidden = false
            } else {
                noFriendsLabel.isHidden = true
            }
            return foundCount
        } else {
            let requestCount = UserRepo.currentUser.friendRequestsReceived.count
            if requestCount == 0 {
                noFriendsLabel.isHidden = false
            } else {
                noFriendsLabel.isHidden = true
            }
            return requestCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "add friend", for: indexPath) as! AddFriendsTableViewCell
        if viewState == .addFriend {
            cell.isFriendRequest = false
            cell.user = userResults[indexPath.row]
        } else {
            cell.isFriendRequest = true
            cell.userUID = UserRepo.currentUser.friendRequestsReceived[indexPath.row]
        }
        return cell
    }
}








