//
//  CommentsModalVC
//  Intercessor
//
//  Created by Allen Lai on 8/26/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class CommentsModalVC: UIViewController {
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var avatarView: NavBarAvatar!
    var barBtnAvatar: UIBarButtonItem!
    
    var poster: User!
    var post: Post!
    
    let nc = NotificationCenter.default
    let commentPlaceholder = "Add a Comment"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTableView.estimatedRowHeight = 68.0
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        // ui stuff
        commentsTableView.tableFooterView = UIView()
        self.tabBarController?.tabBar.isHidden = true
        
        setUpNavBar()
        
        addObservers()
        //        observeComments()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // clean up observer
        Helper.postsRef.child(self.post.postID).child("comments").removeAllObservers()
    }
    
    
    func setUpNavBar() {
        // Avatar
        let frame   = CGRect(x: 0, y: 0, width: 26, height: 26)
        let rightButton  = UIButton(frame: frame)
        rightButton.addTarget(self,
                              action: #selector(self.showProfile),
                              for: .touchUpInside)
        avatarView = NavBarAvatar(frame: frame)
        //        avatarView.containerView.borderColor = UIColor.hex("#ffffff", alpha: 0.3)
        
        avatarView.containerView.cornerRadius = 13
        avatarView.avatar.layer.cornerRadius = 11
        
        avatarView.avatar.loadImageUsingCacheWithUrlString(poster.profilePicURL)
        rightButton.addSubview(avatarView)
        barBtnAvatar = UIBarButtonItem(customView: rightButton)
        
        self.navigationItem.rightBarButtonItem = barBtnAvatar
    }
    
    func showProfile() {
        
        let viewProfileSB = UIStoryboard(name: "ViewProfileVC", bundle: nil)
        let viewProfileViewController = viewProfileSB.instantiateViewController(withIdentifier: "ViewProfile") as! ViewProfileVC
        viewProfileViewController.user = self.poster
        self.navigationController?.pushViewController(viewProfileViewController, animated: true)
        
    }
    
    
    /*
     func observeComments() {
     let commentsRef = Helper.postsRef.child(self.post.postID).child("comments")     // set commentsRef
     commentsRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
     self.post.comments.append(Comment(snapshot: snapshot))
     self.attemptReloadOfTable()
     })
     }
     */
    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.commentsTableView.reloadData()
            // scroll down
            let section = 0
            let numOfRows = self.commentsTableView.numberOfRows(inSection: section)
            let lastRowNum = numOfRows-1
            let ip = IndexPath(row: lastRowNum, section: section)
            if numOfRows > 0 {
                self.commentsTableView.scrollToRow(at: ip, at: .bottom, animated: false)
            }
        })
        
    }
    
    
    @IBAction func close(_ sender: AnyObject) {

            self.dismiss(animated: true, completion: nil)
        
    }
    
    deinit {
        nc.removeObserver(self)
    }
    func keyboardNotification(_ notification: Foundation.Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let bottomConstraint:CGFloat = 0.0
            
            if notification.name == Foundation.Notification.Name.UIKeyboardWillHide {
                self.commentViewBottomConstraint?.constant = bottomConstraint
            } else {
                self.commentViewBottomConstraint?.constant = (endFrame?.size.height ?? 0.0) + bottomConstraint
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            NSLog(self.commentViewBottomConstraint.constant.description)
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func addObservers() {
        nc.addObserver(self, selector: #selector(self.keyboardNotification(_:)), name: Foundation.Notification.Name.UIKeyboardWillHide, object: nil)
        nc.addObserver(self, selector: #selector(self.keyboardNotification(_:)), name: Foundation.Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: - Text View Delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if commentTextView.text == self.commentPlaceholder {
            commentTextView.text = ""
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
            commentTextView.text = commentPlaceholder
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        validateField()
    }
    
    // MARK: - Text View Functions
    func disableSend() {
        self.sendButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.sendButton.alpha = 0.15
        })
    }
    
    func enableSend() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.sendButton.alpha = 1.0
        }, completion: { (finished) -> Void in
            self.sendButton.isUserInteractionEnabled = true
        })
    }
    
    func validateField() {
        let text = self.commentTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if text.characters.count > 1 {
            enableSend()
        } else {
            disableSend()
        }
    }
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
        disableSend()
        let text = self.commentTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // upload to firebase
        post.postComment(Comment(userID: UserRepo.currentUser.uid, content: text, groupID: "1"))
        
        self.commentTextView.text = nil
        self.view.endEditing(true)
        self.attemptReloadOfTable()
    }
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    
}


extension CommentsModalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.comments.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment cell", for: indexPath) as! CommentTableViewCell
        
        if indexPath.row == 0 {
            cell.poster = self.poster
            cell.postForFirstCell = self.post
            return cell
        } else {
            cell.cellComment = post.comments[indexPath.row-1]
            return cell
        }
        
    }
    
}

extension CommentsModalVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



