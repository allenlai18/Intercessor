//
//  FindFriendsVC.swift
//  Intercessor
//
//  Created by Allen Lai on 11/14/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import LilithProgressHUD


class FindFriendsVC: UIViewController {

    @IBOutlet weak var tab0: UIButton!
    @IBOutlet weak var tab1: UIButton!
    @IBOutlet weak var tab2: UIButton!
    @IBOutlet weak var tab3: UIButton!
    @IBOutlet weak var tab4: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var featureComingSoonLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    
    let notification = ALNotification()

    var isFacebookAuthed: Bool = false
    var isGoogleAuthed: Bool = false
    
    
    
    enum ViewState: Int {
        case tab0, tab1, tab2, tab3, tab4
    }
    
    var viewState: ViewState = .tab0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tab0.isSelected = true
        featureComingSoonLabel.isHidden = true
        connectButton.isHidden = true
        tableView.tableFooterView = UIView()
        checkIfEmpty()
        
        for provider in (FIRAuth.auth()?.currentUser?.providerData)! {
            let providerAuth: String = provider.providerID
            if providerAuth == "google.com" {
                isGoogleAuthed = true

            } else if providerAuth == "facebook.com" {
                isFacebookAuthed = true
                findFaceBookFriends()
            }
        }
        
    }
    
    func checkIfEmpty() {
        if UserRepo.currentUser.friendRequestsReceived.count == 0 {
            featureComingSoonLabel.isHidden = false
        }
    }
    
    @IBAction func tab0T(_ sender: Any) {
        if !tab0.isSelected {
            self.viewState = .tab0
            unselectAll()
            tab0.isSelected = true
        }
    }
    
    @IBAction func tab1T(_ sender: Any) {
        if !tab1.isSelected {
            self.viewState = .tab1
            unselectAll()
            tab1.isSelected = true
        }
    }
    
    @IBAction func tab2T(_ sender: Any) {
        if !tab2.isSelected {
            self.viewState = .tab2
            unselectAll()
            tab2.isSelected = true
        }
    }
    @IBAction func tab3T(_ sender: Any) {
        if !tab3.isSelected {
            self.viewState = .tab3
            unselectAll()
            tab3.isSelected = true
        }
    }
    
    @IBAction func tab4T(_ sender: Any) {
        if !tab4.isSelected {
            self.viewState = .tab4
            unselectAll()
            tab4.isSelected = true
        }
    }
    
    
    func unselectAll() {
        tab0.isSelected = false
        tab1.isSelected = false
        tab2.isSelected = false
        tab3.isSelected = false
        tab4.isSelected = false
        featureComingSoonLabel.isHidden = true
        connectButton.isHidden = true
        switch viewState {
        case .tab0:
            if UserRepo.currentUser.friendRequestsReceived.count == 0 {
                featureComingSoonLabel.text = "No Received Friend Requests"
                featureComingSoonLabel.isHidden = false
            }
            return
        case .tab1:
            if UserRepo.currentUser.friendRequestsSent.count == 0 {
                featureComingSoonLabel.text = "No Friend Requests Sent"
                featureComingSoonLabel.isHidden = false
            }
            return
        case .tab2:
            if !isFacebookAuthed {
                connectButton.setImage(UIImage(named: "ConnectWithFacebook"), for: .normal)
                connectButton.isHidden = false
                return
            } else {
                featureComingSoonLabel.text = "No Friend found on Facebook"
                featureComingSoonLabel.isHidden = false
            }

        case .tab3:
            if !isGoogleAuthed {
                connectButton.setImage(UIImage(named: "ConnectWithGoogle"), for: .normal)
                connectButton.isHidden = false
                return
            } else {
                featureComingSoonLabel.text = "No Friend found on Google+"
                featureComingSoonLabel.isHidden = false
            }
        case .tab4:
            connectButton.setImage(UIImage(named: "ConnectAddressBook"), for: .normal)
            connectButton.isHidden = false
            return
        }
        
    }
    func findFaceBookFriends() {
        let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: params)
        request?.start(completionHandler: { (connection, result, error) -> Void in
            
            if error != nil {
                let errorMessage = error?.localizedDescription
                print(errorMessage)
                /* Handle error */
            }
            else {
                print(result)

            }
        })

    
    }

    
    @IBAction func backButtonTapped(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        notification.error(nil, message: "feature not yet implemented")
        
        switch self.viewState {
        case .tab2:
            // connect with facebook
            let loginManager = FBSDKLoginManager()
            loginManager.logIn(withReadPermissions: ["email", "user_friends"], from: self, handler: { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if result!.isCancelled {
                    print("FBLogin cancelled")
                } else {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    self.firebaseLogin(credential)
                }
            })

            
        case .tab3:
            // connect with google
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn()

            break
            
            
        default:
            return
        }
        
        
    }
    func firebaseLogin(_ credential: FIRAuthCredential) {
        if let user = FIRAuth.auth()?.currentUser {
            user.link(with: credential) { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                // update table
                self.tableView.reloadData()
                if credential.provider == "facebook.com"{
                    self.isFacebookAuthed = true
                } else if credential.provider == "google.com"{
                    self.isGoogleAuthed = true
                }
            }
        }
    }
    
}

extension FindFriendsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.viewState == .tab0 {
            return UserRepo.currentUser.friendRequestsReceived.count
        } else if self.viewState == .tab1 {
            return UserRepo.currentUser.friendRequestsSent.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewState {
        case .tab0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "friend cell", for: indexPath) as! UserTableViewCell
            AllFriendsRepo.sharedInstance.fetchUser(userID: UserRepo.currentUser.friendRequestsReceived[indexPath.row]) { (userFound) in
                cell.friend = userFound
            }
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case .tab1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "friend cell", for: indexPath) as! UserTableViewCell
            AllFriendsRepo.sharedInstance.fetchUser(userID: UserRepo.currentUser.friendRequestsSent[indexPath.row]) { (userFound) in
                cell.friend = userFound
            }
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell

            
        case .tab2:
            // facebook
            let cell = tableView.dequeueReusableCell(withIdentifier: "friend cell", for: indexPath) as! UserTableViewCell
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            
            return cell
            
        case .tab3:

            
            
            break
            
        default:
            return UITableViewCell()

        }
        
        return UITableViewCell()

    }
    
    
}


extension FindFriendsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.viewState {
        case .tab0:
            AllFriendsRepo.sharedInstance.fetchUser(userID: UserRepo.currentUser.friendRequestsReceived[indexPath.row]) { (userFound) in
                Segues.showProfile(user: userFound, navigationController: self.navigationController!)
            }
            
        case .tab1:
            AllFriendsRepo.sharedInstance.fetchUser(userID: UserRepo.currentUser.friendRequestsSent[indexPath.row]) { (userFound) in
                Segues.showProfile(user: userFound, navigationController: self.navigationController!)
            }
        default:
            return
        }
    }

}
extension FindFriendsVC:  GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        self.firebaseLogin(credential)
        
    }
}







