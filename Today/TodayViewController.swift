//
//  TodayViewController.swift
//  Today
//
//  Created by John Pollard on 27/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    let cellRowHeight: CGFloat = 22.0
    let dataSource = TodayDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Fetch latest fixtures
        FixtureManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.fixturesUpdated()
            }
        }
        
        GameScoreManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.fixturesUpdated()
            }
        }
        
        self.preferredContentSize = CGSize(width: 0.0, height: self.cellRowHeight * 5.0)
        completionHandler(NCUpdateResult.newData)
    }
    
    func fixturesUpdated() {
        print("Fixture update message received in today view")
        DispatchQueue.main.async(execute: { () -> Void in
            self.dataSource.reloadData()
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: "yeltzland://")
        print("Opening app")
        self.extensionContext?.open(url!, completionHandler: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellRowHeight
    }
}
