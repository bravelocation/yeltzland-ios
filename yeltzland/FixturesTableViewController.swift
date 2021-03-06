//
//  FixturesTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Intents
import WidgetKit

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
    
    #if !targetEnvironment(macCatalyst)
    private let fixturesRefreshControl = UIRefreshControl()
    #endif
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.setupNotificationWatcher()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotificationWatcher()
    }
    
    fileprivate func setupNotificationWatcher() {
        NotificationCenter.default.addObserver(self, selector: #selector(FixturesTableViewController.fixturesUpdated), name: .FixturesUpdated, object: nil)
        print("Setup notification handler for fixture updates")
    }
    
    @objc fileprivate func fixturesUpdated() {
        DispatchQueue.main.async(execute: { () -> Void in
            #if !targetEnvironment(macCatalyst)
            self.fixturesRefreshControl.endRefreshing()
            #endif
            
            self.tableView.reloadData()
            
            let currentMonthIndexPath = IndexPath(row: 0, section: self.currentMonthSection())
            
            // Try to handle case where fixtures may have updated
            if (currentMonthIndexPath.section < FixtureManager.shared.months.count) {
                self.tableView.scrollToRow(at: currentMonthIndexPath, at: UITableView.ScrollPosition.top, animated: true)
            }
        })
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    fileprivate func currentMonthSection() -> Int {
        var monthIndex = 0

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let currentMonth = formatter.string(from: now)
        
        for month in FixtureManager.shared.months {
            if (month == currentMonth) {
                return monthIndex
            }
            
            monthIndex += 1
        }
        
        // No match found, so just start at the top
        return 0
    }
    
    @objc func reloadButtonTouchUp() {
        FixtureManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.fixturesUpdated()
            }
        }
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
        
        #if !targetEnvironment(macCatalyst)
        self.tableView.refreshControl = self.fixturesRefreshControl
        self.fixturesRefreshControl.addTarget(self, action: #selector(FixturesTableViewController.refreshSearchData), for: .valueChanged)
        #endif
    }
    
    @objc private func refreshSearchData(_ sender: Any) {
        FixtureManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.fixturesUpdated()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Reload the table on trait change, in particular to change images on dark mode change
        self.tableView.reloadData()
    }

    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
         if #available(iOS 13.0, *) {
            return [
                UIKeyCommand(title: "Reload", action: #selector(FixturesTableViewController.reloadButtonTouchUp), input: "R", modifierFlags: .command)
            ]
         } else {
            return [
                UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(FixturesTableViewController.reloadButtonTouchUp), discoverabilityTitle: "Reload")
            ]
        }
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return FixtureManager.shared.months.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let months = FixtureManager.shared.months
        if (months.count <= section) {
            return 0
        }
        
        let fixturesForMonth = FixtureManager.shared.fixturesForMonth(months[section])
        
        if (fixturesForMonth == nil || fixturesForMonth?.count == 0) {
            return 0
        }
        
        return fixturesForMonth!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! FixtureTableViewCell

        // Find the fixture
        var currentFixture: Fixture? = nil
        let months = FixtureManager.shared.months
        
        if (months.count > (indexPath as NSIndexPath).section) {
            let fixturesForMonth = FixtureManager.shared.fixturesForMonth(months[(indexPath as NSIndexPath).section])
        
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
        let months = FixtureManager.shared.months
        if (months.count <= section) {
            return ""
        }
        
        let fixturesForMonth = FixtureManager.shared.fixturesForMonth(months[section])
        if (fixturesForMonth == nil || fixturesForMonth?.count == 0) {
            return ""
        }
        
        return fixturesForMonth![0].fixtureMonth
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
}
