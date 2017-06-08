//
//  SettingsTableVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/31/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAuth


class SettingsTableVC: UITableViewController, MFMailComposeViewControllerDelegate {

    
    let notification = ALNotification()

    let messageComposer = MessageComposer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.tableView.backgroundColor = UIColor.clear
        
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 3
        case 3:
            return 1
        case 4:
            return 0
        default:
            print("error")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            // edit profile
            switch indexPath.row {
            case 0:
                return
            default:
                print("error")
                break
            }
        case 1:
            //  More section
            switch indexPath.row {
            case 0:
                // rate app row
                let path = URL(string: "itms-apps://itunes.apple.com/app/id1138332565")
                UIApplication.shared.openURL(path!)
                
            case 1:
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
                
            case 2:
                if (messageComposer.canSendText()) {
                    // Obtain a configured MFMessageComposeViewController
                    let messageComposeVC = messageComposer.configuredMessageComposeViewController()
                    
                    // Present the configured MFMessageComposeViewController instance
                    // Note that the dismissal of the VC will be handled by the messageComposer instance,
                    // since it implements the appropriate delegate call-back
                    present(messageComposeVC, animated: true, completion: nil)
                } else {
                    // Let the user know if his/her device isn't able to send text messages
                    let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
                    errorAlert.show()
                }
                
            case 3:
                
                self.notification.error("Nahhhh", message: "We do it for the Kingdom.")

//                let path = URL(string: "https://www.paypal.me/allenplai")
//                UIApplication.shared.openURL(path!)
            case 4:
                break
            default:
                print("error")
                break
            }
        case 2:
            // About section
            switch indexPath.row {
            case 0:
                // Privacy Policy
                let path = URL(string: "https://docs.google.com/document/d/1UeYVMwjXwAgbDvnQM-wvCQzb_fT6MvOsWsI4zoO4wSA/edit?usp=sharing")
                UIApplication.shared.openURL(path!)
                return
            case 1:
                // Terms
                let path = URL(string: "https://docs.google.com/document/d/1fuVgIeupLRfIzKtxCvsr1BYeamsiokOoY18RhuxsAPU/edit?usp=sharing")
                UIApplication.shared.openURL(path!)
                
            case 2:
                // Support
                let path = URL(string: "https://twitter.com/allenplai")
                UIApplication.shared.openURL(path!)
                
            default:
                print("error")
                break
            }
        case 3:
            // logout section
            switch indexPath.row {
            case 0:
                //  Logout
                do {
                    try FIRAuth.auth()?.signOut()
//                    print(FIRAuth.auth()?.currentUser)
                } catch let error {
                    print(error)
                }
                self.dismiss(animated: true, completion: nil)

                Helper.helper.switchToSignUpLogin()
                
            default:
                print("error")
                break
            }
        default:
            print("error")
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["alai18@terpmail.umd.edu"])
        mailComposerVC.setSubject("FeedBack on Intercessor App")
        mailComposerVC.setMessageBody("Hello, ", isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController!, didFinishWith result: MFMailComposeResult, error: Error!) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsTableVC: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


