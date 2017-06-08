//
//  CommentsPopOverViewController.swift
//  odio
//
//  Created by Xavier Sharp on 8/28/16.
//  Copyright © 2016 XQ Creative, LLC. All rights reserved.
//

import UIKit
import JGProgressHUD


class CommentsPopOverViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var gradientView: UIView!
    @IBOutlet weak var byButton: UIButton!
    @IBOutlet weak var byUsername: UILabel!
    @IBOutlet weak var byProfile: UIImageView!
    @IBOutlet weak var byTimestamp: UILabel!
    
    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var mainComment: UILabel!
    @IBOutlet weak var boxView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var boxViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    
    let nc: NotificationCenter = NotificationCenter.default
    
//    var object: PFObject!         // post
//    var objects = [PFObject]()        // all the comments
  
    var post: Post!
    var parentVC: UIViewController!
    var postUser: User!
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        let hud = JGProgressHUD()
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.show(in: self.view)
        
        disableSend()
        let text = self.commentTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        post.postComment(Comment(userID: UserRepo.currentUser.uid, content: text, groupID: "1"))
        hud.dismiss()
        self.commentTextView.text = nil
        self.view.endEditing(true)
        self.tableView.reloadData()

        
//        Post.comment(object, text: text) { (object, error) -> Void in
//            if error == nil {
//                XQTrack().commented()
//                hud.dismiss()
//                self.objects.append(object)
//                self.commentTextView.text = nil
//                self.view.endEditing(true)
//                
//                self.tableView.reloadData()
//            } else {
//                hud.indicatorView = JGProgressHUDErrorIndicatorView()
//                hud.textLabel.text = "Error"
//                hud.dismiss(afterDelay: 2.0)
//                self.enableSend()
//            }
//        }
    }
    
    @IBAction func didTapOverlay(_ sender: UITapGestureRecognizer) {
        close()
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        close()
    }
    @IBAction func viewAllCommentsTapped(_ sender: Any) {

        self.dismiss(animated: true, completion: {
            let commentsSB = UIStoryboard(name: "CommentsVC", bundle: nil)
            let commentsViewController = commentsSB.instantiateViewController(withIdentifier: "comments") as! CommentsVC
            commentsViewController.poster = self.postUser
            commentsViewController.post = self.post
            commentsViewController.hidesBottomBarWhenPushed = true
            self.parentVC.tabBarController?.tabBar.isHidden = false
            self.parentVC.navigationController?.pushViewController(commentsViewController, animated: true)
            
        })
        


        
    }
    
    fileprivate func close() {
        parentVC.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nc.addObserver(self, selector: #selector(self.keyboardNotification(_:)), name: Foundation.Notification.Name.UIKeyboardWillHide, object: nil)
        nc.addObserver(self, selector: #selector(self.keyboardNotification(_:)), name: Foundation.Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.sendButton.alpha = 0.1
        disableSend()
        
        self.gradientView.addGradient(endLocation: 0.8)
        
        commentTextView.becomeFirstResponder()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCommentCount()
        AllFriendsRepo.sharedInstance.fetchUser(userID: post.userID) { (userFound: User) in
            self.postUser = userFound
            self.setPostData()
        }
        
    }


    fileprivate func setPostData() {
        print(postUser.username)
        self.byUsername.text = "@\(postUser.username)"
        self.byTimestamp.text = timeAgoSinceDate(self.post.date, numericDates: true)
        self.byProfile.loadImageUsingCacheWithUrlString(postUser.profilePicURL)
    }
    
    fileprivate func getCommentCount() {
        
        self.viewAllBtn.titleLabel?.text = "view all \(self.post.comments.count) comments"
        self.viewAllBtn.sizeToFit()
        self.view.layoutIfNeeded()

    }
    
    fileprivate func getRecentComments() {
//        Post.getRecentComments(self.object, limit: 3) { (objects, error) in
//            self.objects = objects!.reversed()
//            self.tableView.reloadData()
//            self.resizeTable()
//        }
        
    }
    
    fileprivate func resizeTable() {
        DispatchQueue.main.async {
            //This code will run in the main thread:
            var frame = self.tableView.frame
            let height = self.tableView.contentSize.height
            frame.size.height = height
            self.tableView.frame = frame
            self.tableViewHeight.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        nc.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func keyboardNotification(_ notification: Foundation.Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let bottomConstraint:CGFloat = 18.0
            
            if notification.name == Foundation.Notification.Name.UIKeyboardWillHide {
                self.boxViewBottomConstraint?.constant = bottomConstraint
            } else {
                self.boxViewBottomConstraint?.constant = (endFrame?.size.height ?? 0.0) + bottomConstraint
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            NSLog(self.boxViewBottomConstraint.constant.description)
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    // MARK: - Text View Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        commentTextView.text = ""
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text.characters.count == 0 {
            commentTextView.text = "Add a Comment"
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validateField()
    }
    
    // MARK: - Text View Functions
    func disableSend() {
        self.sendButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.sendButton.alpha = 0.5
        }) 
    }
    
    func enableSend() {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAllComments" {
            let vc = segue.destination as! CommentsModalVC
            vc.post = self.post
            vc.poster = self.postUser
            vc.hidesBottomBarWhenPushed = true
        }
    }
    
    
}

extension CommentsPopOverViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = self.post.comments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellComment, for: indexPath) as! CommentCell
        cell.comment = comment
        self.tableView.sizeToFit()
        
        return cell
    }
}

extension CommentsPopOverViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

