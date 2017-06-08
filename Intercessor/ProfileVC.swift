//
//  ProfileVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseStorage
import JGProgressHUD

class ProfileVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataSetImageView: UIImageView!
    
    let notification = ALNotification()

    fileprivate var profileImage: UIImage?
    let activityIndicatorInstance: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    var isScrolling         = false
    var index: Int          = 0
    var lastContentOffset: CGFloat = 0.0
    
    enum ViewState: Int {
        case expanded = 0
        case compact = 1
    }
    var viewState: ViewState = .compact {
        didSet {
            updateUI()
        }
    }
    var menuItems = ["Expanded", "Compact"]
    var menuView: BTNavigationDropdownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyDataSetImageView.isHidden = true
        // UI Stuff
        setupMenu()

        ActivityIndicator.startActivityIndicator(vc: self, indicator: activityIndicatorInstance)
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "loadPosts"), object: nil, queue: OperationQueue.current, using: { (notification) in
            // update numberOfPostsLabel
            self.attemptReloadOfTable()
        })
        UserRepo.fetchObserveAllUsersPosts()
        checkIfEmpty()
        
    }
    


    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        self.emptyDataSetImageView.isHidden = true
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
        })
    }
    func checkIfEmpty() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                self.emptyDataSetImageView.isHidden = false
            }
        })
    }


    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    func pickProfileImage(_ sender: AnyObject) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.pickProfileImage(sender)
                })
            })
            return
        }
        
        if authorization == .authorized {
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "ActionTitle"),
                secondaryTitle: NSLocalizedString("Use this one", comment: "Action Title"),
                handler: { (_) -> () in
                    self.presentCamera()
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.profileImage = images[0]
//                        self.profileImageView.image = self.profileImage
                        // save the profile picture
                        let filePath = "\(UserRepo.currentUser.uid)/\(Date.timeIntervalSinceReferenceDate)"
                        let data = UIImageJPEGRepresentation(self.profileImage!, 0.1)
                        let metadata = FIRStorageMetadata()
                        metadata.contentType = "image/jpg"
                        FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
                            in
                            if error != nil {
                                print(error?.localizedDescription)
                                return
                            }
                            let fileUrl = metadata!.downloadURLs![0].absoluteString
                            
                            // update the cache
                            Helper.imageCache.setObject(self.profileImage!, forKey: UserRepo.currentUser.profilePicURL as NSString)
                            
                            // update database profilePicURL
                            Helper.usersRef.child(UserRepo.currentUser.uid).child("profilePicURL").setValue(fileUrl)
                            
                        }
                    })
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Default", comment: "Action Title"), handler: { (_) -> () in
                self.profileImage = nil
//                self.profileImageView.image = UIImage(named: "defaultProfileImage")
                self.saveUserProfilePictureAsDefault()
                }, secondaryHandler: nil))
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .cancel, handler: { (_) -> () in
//                self.profileImage = nil
//                self.profileImageView.image = UIImage(named: "defaultProfileImage")
                }, secondaryHandler: nil))

            present(controller, animated: true, completion: nil)
        }
    }
    func saveUserProfilePictureAsDefault() {
        Helper.imageCache.setObject(UIImage(named: "defaultProfileImage")!, forKey: UserRepo.currentUser.profilePicURL as NSString)
        Helper.usersRef.child(UserRepo.currentUser.uid).child("profilePicURL").setValue("")
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show comments from profile" {
            let cell = sender as! ProfilePostsTableViewCell
            let commentsViewController = segue.destination as! CommentsVC
            commentsViewController.post = cell.cellPost
            commentsViewController.poster = User(selfUser: UserRepo.currentUser)
            
            commentsViewController.hidesBottomBarWhenPushed = true
        }
    }

}



extension ProfileVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserRepo.currentUser == nil {
            return 1
        } else {
            return UserRepo.currentUser.currPosts.count + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as! ProfileHeaderTableViewCell
            cell.user = User(selfUser: UserRepo.currentUser)
            cell.parentVC = self
            return cell
        } else {
            if self.viewState == .expanded {
                let cell = tableView.dequeueReusableCell(withIdentifier: "post cell", for: indexPath) as! PostTableViewCell
                cell.cellPost = UserRepo.currentUser.currPosts[indexPath.row-1]
                cell.parentVC = self
                
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            } else {

                let cell = tableView.dequeueReusableCell(withIdentifier: "profile cell", for: indexPath) as! ProfilePostsTableViewCell
                cell.cellPost = UserRepo.currentUser.currPosts[indexPath.row-1]
                
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            
            }
        }
        
    }
    // edit mode and deleting rows
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCellEditingStyle.delete {
//            var rowPost: Post
//            
//            rowPost = UserRepo.currentUser.currPosts[indexPath.row]
//            // delete post
//            rowPost.deletePost()
//            // update the numberOfPostsLabel
//            if UserRepo.currentUser.currPosts.count == 1 {
//                numberOfPostsLabel.text = "1 Post"
//            } else {
//                numberOfPostsLabel.text = String(UserRepo.currentUser.currPosts.count) + " Posts"
//            }
//            self.usersPostsTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
//            self.setEditing(false, animated: true)
//        }
//    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
//        return false
    }
    
    @objc(tableView:editingStyleForRowAtIndexPath:) func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
}

extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            return
        }
        if viewState == .compact {
            Segues.showComments(poster: User(selfUser: UserRepo.currentUser), post: UserRepo.currentUser.currPosts[indexPath.row-1], navigationController: self.navigationController!)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            if self.viewState == .expanded {
                return tableView.bounds.height
            } else {
                return UITableViewAutomaticDimension
            }
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            if self.viewState == .expanded {
                return tableView.bounds.height
            } else {
                return UITableViewAutomaticDimension
            }
        }

    }
}


extension ProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
//        self.profileImageView.image! = self.profileImage!
        picker.dismiss(animated: true, completion: nil)
    }
}



extension ProfileVC {
    
    func updateUI() {
        if self.viewState == .expanded {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        self.attemptReloadOfTable()
    }
    
    // MARK: - Dropdown Menu
    func setupMenu() {
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                            containerView: self.navigationController!.view,
                                            title: "My Profile",
                                            items: menuItems as [AnyObject])
        
        // Cells
        menuView.cellTextLabelFont      = UIFont(name: "Lato-Light", size: 14)
        menuView.cellTextLabelColor     = UIColor.white
        menuView.cellSeparatorColor     = UIColor.white
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        //        menuView.checkMarkImage         = UIImage(named: "menu-checkmark")
        
        
        // Title View
        menuView.navigationBarTitleFont = UIFont(name: "Lato-Regular", size: 18.0)
        menuView.menuTitleColor         = UIColor.white
        menuView.arrowPadding           = 13.0
        
        // Misc
        menuView.animationDuration      = 0.2
        menuView.maskBackgroundOpacity  = 0.4
        menuView.shouldChangeTitleText = false
        
        self.navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            if indexPath == 0 {
                self.viewState = .expanded
            } else {
                self.viewState = .compact
            }
        }
        if let menuTable = menuView.getTable() as? BTTableView {
            let indexPath = IndexPath(row: 0, section: 0)
            menuTable.tableView(menuTable, didSelectRowAt: indexPath)
            menuView.rotateArrow()
        }
    }

    
}

