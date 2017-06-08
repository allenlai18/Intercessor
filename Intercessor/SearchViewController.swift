//
//  SearchViewController.swift
//  Odio
//
//  Created by Xavier Sharp on 12/28/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var hashTagsFound: [String] = []
    var usersFound: [User] = []
    
    var noResultsFound: Bool = false
    
    enum ViewState: Int {
        case users = 0
        case hashTags = 1
    }
    var viewState: ViewState = .users {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var hashtagsButton: UIButton!
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchTextField.becomeFirstResponder()
    }
    
    
    
    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        var count = 0
        if viewState == .users {
            count = usersFound.count
        } else {
            count = hashTagsFound.count
        }
        if count == 0 {
            noResultsFound = true
        } else {
            noResultsFound = false
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }


    // MARK: - IB Actions

    @IBAction func usersButtonTapped(_ sender: UIButton) {
        viewState = .users
    }

    @IBAction func hashtagsButtonTapped(_ sender: UIButton) {
        viewState = .hashTags
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        let _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func searchQueryChanged(_ sender: UITextField) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
        self.perform(#selector(self.performSearch), with: nil, afterDelay: 0.5)
        
    }



    // MARK: - Search Actions

    func performSearch() {
//        print("SearchVC.swift - performSearch()")
        if viewState == .users {
            searchUsers()
        } else {
            searchHashtags()
        }
    }

    func searchUsers() {
        Search.users(str: searchTextField.text!) { (users) -> Void in
            self.usersFound = users as! [User]
            self.attemptReloadOfTable()
        }
    }

    func searchHashtags() {
//        print(searchTextField.text!)
        Search.hashTags(str: searchTextField.text!) { (foundHashTags) in
            print(self.hashTagsFound)
            self.hashTagsFound = foundHashTags
            self.attemptReloadOfTable()
        }
    }

    // MARK: - Misc
    func animateUnderline(selectedView: UIView) {
        DispatchQueue.main.async(execute: {
            var frame = self.underlineView.frame
            frame.origin.x = selectedView.frame.origin.x
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.underlineView.frame = frame
            })
        })
    }
}

extension SearchViewController: UITableViewDataSource {
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noResultsFound {
            return 1
        }
        if viewState == .users {
            return usersFound.count
        } else {
            return hashTagsFound.count
        }

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noResultsFound {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCellEmpty, for: indexPath) as! EmptyCell
            if viewState == .users {
                cell.loadText(type: kSearchTypeUsers)
            } else {
                cell.loadText(type: kSearchTypeHashtags)
            }
            return cell
        }
        if viewState == .hashTags {
            let hashTagString = hashTagsFound[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: kCellHashtag, for: indexPath) as! HashtagCell
            cell.parentVC = self
            cell.loadData(tag: hashTagString)
            return cell
        } else {
            let cellUser = usersFound[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "friend cell", for: indexPath) as! UserTableViewCell
            cell.friend = cellUser
            return cell
            
        }
        
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension SearchViewController {
    
    func updateUI() {
        if viewState == .users {
            searchTextField.placeholder = kPHSearchUsers
            animateUnderline(selectedView: usersButton)
            searchUsers()
        } else {
            searchTextField.placeholder = kPHSearchHashtags
            animateUnderline(selectedView: hashtagsButton)
            searchHashtags()
        }
    }
    
    
}




extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewState == .hashTags {
            
        } else {
            if let _ = tableView.cellForRow(at: indexPath) as? UserTableViewCell {
                Segues.showProfile(user: usersFound[indexPath.row], navigationController: self.navigationController!)
            }
        }

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}





