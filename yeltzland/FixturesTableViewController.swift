//
//  FixturesTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Intents

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class FixturesTableViewController: UITableViewController {
    
    var reloadButton: UIBarButtonItem!
    private let cellIdentifier: String = "FixtureTableViewCell"
    private let fixturesRefreshControl = UIRefreshControl()
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.setupNotificationWatcher()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotificationWatcher()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler for fixture updates")
    }
    
    fileprivate func setupNotificationWatcher() {
        NotificationCenter.default.addObserver(self, selector: #selector(FixturesTableViewController.fixturesUpdated), name: NSNotification.Name(rawValue: FixtureManager.FixturesNotification), object: nil)
        print("Setup notification handler for fixture updates")
    }
    
    @objc fileprivate func fixturesUpdated(_ notification: Notification) {
        print("Fixture update message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.fixturesRefreshControl.endRefreshing()
            self.tableView.reloadData()
            
            let currentMonthIndexPath = IndexPath(row: 0, section: self.currentMonthSection())
            
            // Try to handle case where fixtures may have updated
            if (currentMonthIndexPath.section < FixtureManager.instance.months.count) {
                self.tableView.scrollToRow(at: currentMonthIndexPath, at: UITableView.ScrollPosition.top, animated: true)
            }
        })
    }
    
    fileprivate func currentMonthSection() -> Int {
        var monthIndex = 0

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let currentMonth = formatter.string(from: now)
        
        for month in FixtureManager.instance.months {
            if (month == currentMonth) {
                return monthIndex
            }
            
            monthIndex += 1
        }
        
        // No match found, so just start at the top
        return 0
    }
    
    @objc func reloadButtonTouchUp() {
        FixtureManager.instance.getLatestFixtures()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go get latest fixtures in background
        self.reloadButtonTouchUp()

        // Setup navigation
        self.navigationItem.title = "Fixtures"
        
        self.view.backgroundColor = AppColors.systemBackground
        self.tableView.separatorColor = AppColors.systemBackground
        
        self.tableView.register(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        
        // Setup refresh button
        self.reloadButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(FixturesTableViewController.reloadButtonTouchUp)
        )
        self.reloadButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = self.fixturesRefreshControl
        } else {
            self.tableView.addSubview(self.fixturesRefreshControl)
        }
        
        self.fixturesRefreshControl.addTarget(self, action: #selector(FixturesTableViewController.refreshSearchData), for: .valueChanged)
        self.setupHandoff()
    }
    
    @objc private func refreshSearchData(_ sender: Any) {
        FixtureManager.instance.getLatestFixtures()
    }

    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(FixturesTableViewController.reloadButtonTouchUp), discoverabilityTitle: "Reload")
        ]
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return FixtureManager.instance.months.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let months = FixtureManager.instance.months
        if (months.count <= section) {
            return 0
        }
        
        let fixturesForMonth = FixtureManager.instance.fixturesForMonth(months[section])
        
        if (fixturesForMonth == nil || fixturesForMonth?.count == 0) {
            return 0
        }
        
        return fixturesForMonth!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! FixtureTableViewCell

        // Find the fixture
        var currentFixture: Fixture? = nil
        let months = FixtureManager.instance.months
        
        if (months.count > (indexPath as NSIndexPath).section) {
            let fixturesForMonth = FixtureManager.instance.fixturesForMonth(months[(indexPath as NSIndexPath).section])
        
            if (fixturesForMonth != nil && fixturesForMonth?.count > (indexPath as NSIndexPath).row) {
                currentFixture = fixturesForMonth![(indexPath as NSIndexPath).row]
            }
        }

        if let fixture = currentFixture {
            cell.assignFixture(fixture)
        }
        
        return cell
    }
    
    override func tableView( _ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let months = FixtureManager.instance.months
        if (months.count <= section) {
            return ""
        }
        
        let fixturesForMonth = FixtureManager.instance.fixturesForMonth(months[section])
        if (fixturesForMonth == nil || fixturesForMonth?.count == 0) {
            return ""
        }
        
        return fixturesForMonth![0].fixtureMonth
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(named: "light-blue")
        header.textLabel!.textColor = UIColor(named: "yeltz-blue")
        header.textLabel!.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.OtherSectionTextSize)!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 33.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    // - MARK Handoff
    @objc func setupHandoff() {
        // Set activity for handoff
        let activity = NSUserActivity(activityType: "com.bravelocation.yeltzland.fixtures")
        
        // Eligible for handoff
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.title = "Yeltz Fixture List"
        
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true            
            activity.suggestedInvocationPhrase = "Fixture List"
            activity.persistentIdentifier = String(format: "%@.com.bravelocation.yeltzland.fixtures", Bundle.main.bundleIdentifier!)
        }
                
        // Set the title
        activity.needsSave = true
        
        self.userActivity = activity
        self.userActivity?.becomeCurrent()
    }
}
