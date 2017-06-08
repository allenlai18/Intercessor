//
//  HomeVC.swift
//  Intercessor
//
//  Created by Allen Lai on 9/12/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD
import MessageUI
import JDStatusBarNotification
import Firebase
import GoogleMobileAds


class HomeVC: UIViewController, GADNativeExpressAdViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableEmptyLabel: UILabel!
    
    let notification = ALNotification()

    var isScrolling         = false
    var index: Int = 0
    var lastContentOffset: CGFloat = 0.0
    let activityIndicatorInstance: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    enum ViewState: Int {
        case expanded = 0
        case compact = 1
    }
    var viewState: ViewState = .expanded {
        didSet {
            updateUI()
        }
    }
    var menuItems = ["Expanded", "Compact"]
    var menuView: BTNavigationDropdownMenu!
    
    
    // Google Ad variables
    var adsToLoad = [GADNativeExpressAdView]()
    var loadStateForAds = [GADNativeExpressAdView: Bool]()
    let adUnitID = "ca-app-pub-5153838714113670/4506942345"
    let adInterval = 10
    let adViewHeight = CGFloat(500)

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Helper.helper.deleteUser(userID: "7yVuPQvE7dWop3MoiSn4jrJlX543")    // delete john kezler
        
//        Discover.saveFeaturedHashTags()
//        Discover.saveFeaturedUsers()

        if FIRAuth.auth()?.currentUser == nil {     // user not logged in!!!!!!
            Helper.helper.switchToSignUpLogin()
            return
        }
        self.tableEmptyLabel.isHidden = true

        
        // fetching stuff
        ActivityIndicator.startActivityIndicator(vc: self, indicator: activityIndicatorInstance)
        
        addNotificationObservers()
        setupMenu()
        
        tableView.tableFooterView = UIView()
        
        // do all the fetching and initial set up
        UserRepo.fetchCurrentUserBasicData()

        self.configureRefreshControl()
        
        
        
        // **********    Google Ad Stuff    *************
//        tableView.register(UINib(nibName: "NativeExpressAd", bundle: nil), forCellReuseIdentifier: "NativeExpressAdViewCell")
        
    }
    
    

    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        // sort newfeed by dates
        UserRepo.currentUser.currNewsFeedPosts.sort{ (object1, object2) -> Bool in
            let post1 = object1 as! Post
            let post2 = object2 as! Post
            return (post1.date as Date).compare(post2.date as Date) == .orderedDescending
        }
        
        // **********    Google Ad Stuff    *************
//        addNativeExpressAds()
//        preloadNextAd()
        if UserRepo.currentUser.currNewsFeedPosts.isEmpty{
            self.tableEmptyLabel.isHidden = false
        } else {
            self.tableEmptyLabel.isHidden = true
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl?.endRefreshing()
            } else {
                // Fallback on earlier versions
            }
        })

    }
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleReloadTable), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    // MARK: cell methods
    func goToComments(post: Post) {
        Segues.goToPopoverComments(post: post, selfParentVC: self, tabBarC: self.tabBarController as! TabBarController)
    }
 
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constants.NotificationNames.reloadMyFeed), object: nil, queue: OperationQueue.main, using: { (notification) in
            self.attemptReloadOfTable()
           
        })

//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constants.NotificationNames.updateNotificationsBadge), object: nil, queue: OperationQueue.current, using: { (notification) in
//            if #available(iOS 10.0, *) {
//                self.navigationController?.tabBarController?.tabBar.items![3].badgeColor = UIColor.hex("#AC2A3A", alpha: 1)
//            } else {
//                // Fallback on earlier versions
//            }
//            if UserRepo.currentUser.numberOfNotificationsUnseen > 0 {
//                self.navigationController?.tabBarController?.tabBar.items![3].badgeValue = String(UserRepo.currentUser.numberOfNotificationsUnseen)
//            } else {
//                self.navigationController?.tabBarController?.tabBar.items![3].badgeValue = nil
//            }
//            UIApplication.shared.applicationIconBadgeNumber = UserRepo.currentUser.numberOfNotificationsUnseen
//        })
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constants.NotificationNames.updateMessagesBadge), object: nil, queue: OperationQueue.current, using: { (notification) in
            if #available(iOS 10.0, *) {
                self.navigationController?.tabBarController?.tabBar.items![1].badgeColor = UIColor.hex("#AC2A3A", alpha: 1)
            } else {
                // Fallback on earlier versions
            }
            if UserRepo.currentUser.numberOfMessagesUnseen > 0 {
                self.navigationController?.tabBarController?.tabBar.items![1].badgeValue = String(UserRepo.currentUser.numberOfMessagesUnseen)
            } else {
                self.navigationController?.tabBarController?.tabBar.items![1].badgeValue = nil
            }
            UIApplication.shared.applicationIconBadgeNumber = UserRepo.currentUser.numberOfMessagesUnseen
        
        })

    }
    



}


extension HomeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserRepo.currentUser == nil {
            return 0
        } else {
            return UserRepo.currentUser.currNewsFeedPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewState == .expanded {
            
            // ******** google Ad stuff START
            if let nativeExpressAdView = UserRepo.currentUser.currNewsFeedPosts[indexPath.row] as? GADNativeExpressAdView {
                let reusableAdCell = tableView.dequeueReusableCell(withIdentifier: "NativeExpressAdViewCell", for: indexPath)
                // Remove previous GADNativeExpressAdView from the content view before adding a new one.
                for subview in reusableAdCell.contentView.subviews {
                    subview.removeFromSuperview()
                }
                reusableAdCell.contentView.addSubview(nativeExpressAdView)
                // Center GADNativeExpressAdView in the table cell's content view.
                nativeExpressAdView.center = reusableAdCell.contentView.center
                return reusableAdCell
            }
            // ******** google Ad stuff END
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "post cell", for: indexPath) as! PostTableViewCell
            cell.cellPost = UserRepo.currentUser.currNewsFeedPosts[indexPath.row] as! Post
            cell.parentVC = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "news feed cell", for: indexPath) as! NewsFeedTableViewCell
            cell.cellPost = UserRepo.currentUser.currNewsFeedPosts[indexPath.row] as! Post
            cell.parentVC = self
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }

        
    }
    

}


extension HomeVC: UITableViewDelegate {

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = UserRepo.currentUser.currNewsFeedPosts[indexPath.row] as! Post
        if viewState == .compact {
            Segues.showComments(post: post, navigationController: self.navigationController!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.viewState == .expanded {
            if let tableItem = UserRepo.currentUser.currNewsFeedPosts[indexPath.row] as? GADNativeExpressAdView {
                let isAdLoaded = loadStateForAds[tableItem]
                return isAdLoaded == true ? adViewHeight : 0
            }
            return tableView.bounds.height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.viewState == .expanded {
            return tableView.bounds.height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    

    func scrollToTop() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

}



extension HomeVC {
    
    func updateUI() {

        if self.viewState == .expanded {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Dropdown Menu
    func setupMenu() {
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                            containerView: self.navigationController!.view,
                                            title: "My Feed",
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



extension HomeVC {
    
    // MARK: - Google Ad Stuff
    // Adds native express ads to the tableViewItems list.
    func addNativeExpressAds() {
        var index = adInterval
        // Ensure subview layout has been performed before accessing subview sizes.
        tableView.layoutIfNeeded()
        while index < UserRepo.currentUser.currNewsFeedPosts.count {
            let adSize = GADAdSizeFromCGSize(
                CGSize(width: tableView.contentSize.width, height: adViewHeight))
            guard let adView = GADNativeExpressAdView(adSize: adSize) else {
                print("GADNativeExpressAdView failed to initialize at index \(index)")
                return
            }
            adView.adUnitID = adUnitID
            adView.rootViewController = self
            adView.delegate = self
            
            UserRepo.currentUser.currNewsFeedPosts.insert(adView, at: index)
            adsToLoad.append(adView)
            loadStateForAds[adView] = false
            
            index += adInterval
        }
    }
    
    //  Preload native express ads sequentially. Dequeue and load next ad from `adsToLoad` list.
    func preloadNextAd() {
        if !adsToLoad.isEmpty {
            let ad = adsToLoad.removeFirst()
            ad.load(GADRequest())
        }
    }
    
    // MARK: - GADNativeExpressAdView delegate methods
    func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
        // Mark native express ad as succesfully loaded.
        loadStateForAds[nativeExpressAdView] = true
        // Load the next ad in the adsToLoad list.
        preloadNextAd()
    }
    
    func nativeExpressAdView(_ nativeExpressAdView: GADNativeExpressAdView,
                             didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed to receive ad: \(error.localizedDescription)")
        // Load the next ad in the adsToLoad list.
        preloadNextAd()
    }
    
}



