//
//  TwitterUserTimelineViewController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import SafariServices

class TwitterUserTimelineViewController: TWTRTimelineViewController, TWTRTweetViewDelegate, SFSafariViewControllerDelegate {
    
    var userScreenName: String!
    var reloadButton: UIBarButtonItem!
    var timer: Timer!
    
    let timerInterval = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = TWTRAPIClient()
        self.dataSource = TWTRUserTimelineDataSource(screenName: self.userScreenName, apiClient: client)
        self.tweetViewDelegate = self
        
        // Setup navigation
        self.navigationItem.title = "@\(self.userScreenName!)"

        self.reloadButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(TwitterUserTimelineViewController.reloadData)
        )
        
        self.reloadButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
        
        self.view.backgroundColor = UIColor.white
        self.tableView.separatorColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
   
    func tweetView(_ tweetView: TWTRTweetView, didTap url: URL) {
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(TwitterUserTimelineViewController.reloadData), discoverabilityTitle: "Reload")
        ]
    }

    // MARK: - Nav bar actions
    @objc func reloadData() {
        self.refresh()
        
        // Set a timer to refresh the data after interval period
        if (self.timer != nil) {
            self.timer.invalidate()
        }

        self.timer = Timer.scheduledTimer(timeInterval: self.timerInterval, target: (self as AnyObject), selector: #selector(UITableView.reloadData), userInfo: nil, repeats: false)
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
