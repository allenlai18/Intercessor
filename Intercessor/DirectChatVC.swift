//
//  ChatVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/25/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class DirectChatVC: JSQMessagesViewController {
    
    var directMessage: DirectMessage!
    var friend: User!

    var JSQmessages = [JSQMessage]()
//    var senderAvatarImage: JSQMessagesAvatarImage!
//    var receiverAvatarImage: JSQMessagesAvatarImage!
    
    var veryFirstMessage: Bool = false
    
    @IBOutlet weak var bgImage: UIImageView!
    
    
    var indexPathOfCellFrom: IndexPath!

    // is User typing stuff
    var userIsTypingRef: FIRDatabaseReference!
    var usersTypingQuery: FIRDatabaseQuery!
    fileprivate var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        
//        let imageView: UIImageView = UIImageView()  // load up currentUser profile image
//        imageView.loadImageUsingCacheWithUrlString(UserRepo.currentUser.profilePicURL)
//        senderAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: imageView.image, diameter: 30)
        // load the recieverImage if needed
//        if receiverAvatarImage == nil {
//            let imageView: UIImageView = UIImageView()  // load up currentUser profile image
//            imageView.loadImageUsingCacheWithUrlString(friend.profilePicURL)
//            receiverAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: imageView.image, diameter: 30)
//        }
        
        // UI Stuff
        setUpNavBar()
        
        self.tabBarController?.tabBar.isHidden = true
        self.keyboardController.textView.keyboardAppearance = .light
        
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.backgroundView = bgImage
        
        self.keyboardController.textView.backgroundColor = UIColor.white
        self.inputToolbar.contentView.backgroundColor = UIColor.white
        self.keyboardController.textView.textColor = UIColor.black
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor.black, for: UIControlState())
        
        
        // init setup
        self.senderId = UserRepo.currentUser.uid
        self.senderDisplayName = UserRepo.currentUser.displayName
        if !veryFirstMessage {
            observeMessages()
        }
        observeTyping()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Helper.directMessagesRef.child(directMessage.DMID).child(UserRepo.currentUser.uid+"unread").setValue(false)

        
    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func observeTyping() {
        let typingIndicatorRef = Helper.directMessagesRef.child(directMessage.DMID).child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(self.senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        usersTypingQuery.observe(.value, with: { (snapshot) in
            if snapshot.childrenCount == 1 && self.isTyping {
                return
            }
            // Are there others typing?
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
        })
    }
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    func observeMessages() {
        // change all the messages to JSQmessages
        for message in self.directMessage.messages {
            self.JSQmessages.append(message.toJSQMessage())
        }
        self.collectionView.reloadData()
        // add observer for more messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: self.directMessage.DMID), object: nil, queue: OperationQueue.main, using: { (notification) in
            if let newMessage = notification.userInfo?["newMessage"] as? Message {
                self.JSQmessages.append(newMessage.toJSQMessage())
            } else {
                print("error adding message")
            }
            self.collectionView.reloadData()
        })

    }
    
    
    func setUpNavBar() {
        self.navigationItem.title = friend.displayName
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Book", size: 18)!]
        var barBtnAvatar: UIBarButtonItem!
        var avatarView: NavBarAvatar!

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
        
        avatarView.avatar.loadImageUsingCacheWithUrlString(friend.profilePicURL)
        rightButton.addSubview(avatarView)
        barBtnAvatar = UIBarButtonItem(customView: rightButton)
        
        self.navigationItem.rightBarButtonItem = barBtnAvatar
    }
    func showProfile() {
        
        let viewProfileSB = UIStoryboard(name: "ViewProfileVC", bundle: nil)
        let viewProfileViewController = viewProfileSB.instantiateViewController(withIdentifier: "ViewProfile") as! ViewProfileVC
        viewProfileViewController.user = self.friend
        self.navigationController?.pushViewController(viewProfileViewController, animated: true)
        
    }

    
    // MARK: JSQMessageController
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let messageToSend = Message(mediaType: "TEXT", senderID: senderId, senderName: self.senderDisplayName, content: text, messageType: .none)
        if veryFirstMessage {
            let newDM = DirectMessage(firstUser: UserRepo.currentUser.uid, otherUser: friend.uid)
            newDM.saveNewDirectMessage()
            veryFirstMessage = false
            // set up to make up for
            directMessage = newDM
            observeMessages()
            newDM.sendNewMessage(messageToSend)
            
        } else {
            directMessage.sendNewMessage(messageToSend)
        }
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert:UIAlertAction) in
            
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.getMediaFrom(kUTTypeMovie)
        }
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
        //        let imagePicker = UIImagePickerController()
        //        imagePicker.delegate = self
        //        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    func getMediaFrom(_ type: CFString) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    func sendMedia(_ picture: UIImage?, video: URL?) {
        if let picture = picture {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
                in
                if error != nil {
                    print(error)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                self.directMessage.sendNewMessage(Message(mediaType: "PHOTO", senderID: self.senderId, senderName: self.senderDisplayName, content: fileUrl, messageType: .none))

            }
            
        } else if let video = video {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = try? Data(contentsOf: video)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
                in
                if error != nil {
                    print(error)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                self.directMessage.sendNewMessage(Message(mediaType: "VIDEO", senderID: self.senderId, senderName: self.senderDisplayName, content: fileUrl, messageType: .none))
                
    

            }
        }
    }
    
    
    
    // TIMESTAMP FOR MESSAGE START
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let messageToPopulate = self.directMessage.messages[indexPath.row]
        if messageToPopulate.needTimeStampInChat {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: messageToPopulate.date)
        } else {
            return nil
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let messageToPopulate = self.directMessage.messages[indexPath.row]
        if messageToPopulate.needTimeStampInChat {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    // TIMESTAMP FOR MESSAGE END
    
    
    
    // MARK:: collectionView delegate methods 
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = JSQmessages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if message.senderId == self.senderId {
            return bubbleFactory!.outgoingMessagesBubbleImage(with: UIColor.hex("#AC2A3A", alpha: 1))
        } else {
            return bubbleFactory!.incomingMessagesBubbleImage(with: UIColor.hex("#E5E5EA", alpha: 1))
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
//        let message: JSQMessage = JSQmessages[indexPath.item]
//        if message.senderId == UserRepo.currentUser.uid {
//            return senderAvatarImage
//        } else {
//            return receiverAvatarImage
//        }
        return nil
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return JSQmessages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JSQmessages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell is being nil when its a video
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = JSQmessages[(indexPath as NSIndexPath).item]
        if !message.isMediaMessage {
            if message.senderId == self.senderId {
                cell.textView.textColor = UIColor.white
            } else {
                cell.textView.textColor = UIColor.black
            }
        }
        
        return cell
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = JSQmessages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
}


extension DirectChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            sendMedia(nil, video: video)
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}






