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

class GroupChatVC: JSQMessagesViewController {
    

    // this is optional but better if it is set before loaded
    var groupMessage: GroupMessage!
    
    
    var JSQmessages = [JSQMessage]()
    
    var senderAvatarImage: JSQMessagesAvatarImage!
    var receiverAvatarImage: JSQMessagesAvatarImage!

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
    
    
    @IBOutlet weak var bgImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        let imageView: UIImageView = UIImageView()  // load up users profile image
        imageView.loadImageUsingCacheWithUrlString(UserRepo.currentUser.profilePicURL)
        senderAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: imageView.image, diameter: 30)
        
        // UI Stuff
        setupNavBarWithGroup()
        self.tabBarController?.tabBar.isHidden = true
        self.keyboardController.textView.keyboardAppearance = .dark
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.backgroundView = bgImage
        
        self.keyboardController.textView.backgroundColor = UIColor(red: 61/255, green: 60/255, blue: 65/255, alpha: 1)
        self.inputToolbar.contentView.backgroundColor = UIColor(red: 61/255, green: 60/255, blue: 65/255, alpha: 1)
        self.keyboardController.textView.textColor = UIColor.white
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor.white, for: UIControlState())
        
        // init setup
        self.senderId = UserRepo.currentUser.uid
        self.senderDisplayName = UserRepo.currentUser.displayName
        
        
        observeMessages()
        observeTyping()
        
    

    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func observeTyping() {
        let typingIndicatorRef = Helper.groupMessagesRef.child(self.groupMessage.groupID).child("typingIndicator")
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
        let groupMessageRef = Helper.groupMessagesRef.child(groupMessage.GMID).child("messages")     // set messageRef
        groupMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let newMessage = Message(snapshot: snapshot)
            self.groupMessage.messages.append(newMessage)
            self.JSQmessages.append(newMessage.toJSQMessage())
            self.collectionView.reloadData()
            
        })
    }
    
    
    func setupNavBarWithGroup() {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.loadImageUsingCacheWithUrlString(groupMessage.groupPicURL)
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont(name: "Avenir-Book", size: 18)
        nameLabel.text = groupMessage.otherUserNameOrGroupName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // TODO:: send the message
        groupMessage.sendNewMessage(Message(mediaType: "TEXT", senderID: senderId, senderName: self.senderDisplayName, content: text, messageType: .none))
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
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                self.groupMessage.sendNewMessage(Message(mediaType: "PHOTO", senderID: self.senderId, senderName: self.senderDisplayName, content: fileUrl, messageType: .none))
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
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                self.groupMessage.sendNewMessage(Message(mediaType: "VIDEO", senderID: self.senderId, senderName: self.senderDisplayName, content: fileUrl, messageType: .none))
    
            }
        }
    }
    
    // MARK:: collectionView delegate methods 
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = JSQmessages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if message.senderId == self.senderId {
            return bubbleFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 140/255, green: 126/255, blue: 255/255, alpha: 1.0))
        } else {
            return bubbleFactory!.incomingMessagesBubbleImage(with: UIColor.white)
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = JSQmessages[indexPath.item]
        if message.senderId == UserRepo.currentUser.uid {
            return senderAvatarImage
        } else {
            return receiverAvatarImage
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return JSQmessages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JSQmessages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = JSQmessages[(indexPath as NSIndexPath).item]
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.black
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


extension GroupChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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






