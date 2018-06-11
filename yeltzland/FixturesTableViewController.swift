//
//  FixturesTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FixturesTableViewController: UITableViewController {
    
    var reloadButton: UIBarButtonItem!
    
    override init(style: UITableViewStyle) {
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
            self.tableView.reloadData()
            
            let currentMonthIndexPath = IndexPath(row: 0, section: self.currentMonthSection())
            
            // Try to handle case where fixtures may have updated
            if (currentMonthIndexPath.section < FixtureManager.instance.Months.count) {
                self.tableView.scrollToRow(at: currentMonthIndexPath, at: UITableViewScrollPosition.top, animated: true)
            }
        })
    }
    
    fileprivate func currentMonthSection() -> Int {
        var monthIndex = 0

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let currentMonth = formatter.string(from: now)
        
        for month in FixtureManager.instance.Months {
            if (month == currentMonth) {
                return monthIndex
            }
            
            monthIndex = monthIndex + 1
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
        
        self.view.backgroundColor = AppColors.OtherBackground
        self.tableView.separatorColor = AppColors.OtherSeparator
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "FixtureCell")
        
        // Setup refresh button
        self.reloadButton = UIBarButtonItem(
            title: "Reload",
            style: .plain,
            target: self,
            action: #selector(FixturesTableViewController.reloadButtonTouchUp)
        )
        self.reloadButton.FAIcon = FAType.FARotateRight
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        self.navigationController?.navigationBar.tintColor = AppColors.NavBarTintColor
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
        
        self.setupHandoff()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return FixtureManager.instance.Months.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let months = FixtureManager.instance.Months;
        if (months.count <= section) {
            return 0
        }
        
        let fixturesForMonth = FixtureManager.instance.FixturesForMonth(months[section])
        
        if (fixturesForMonth == nil || fixturesForMonth?.count == 0) {
            return 0
        }
        
        return fixturesForMonth!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "FixtureCell")

        // Find the fixture
        var currentFixture:Fixture? = nil
        let months = FixtureManager.instance.Months;
        
        if (months.count > (indexPath as NSIndexPath).section) {
            let fixturesForMonth = FixtureManager.instance.FixturesForMonth(months[(indexPath as NSIndexPath).section])
        
            if (fixturesForMonth != nil && fixturesForMonth?.count > (indexPath as NSIndexPath).row) {
                currentFixture = fixturesForMonth![(indexPath as NSIndexPath).row]
            }
        }

        cell.selectionStyle = .none
        cell.accessoryType = .none
        
        var resultColor = AppColors.FixtureNone
        
        if (currentFixture == nil) {
            resultColor = AppColors.FixtureNone
        } else if (currentFixture!.teamScore == nil || currentFixture!.opponentScore == nil) {
            resultColor = AppColors.FixtureNone
        } else if (currentFixture!.teamScore > currentFixture!.opponentScore) {
            resultColor = AppColors.FixtureWin
        } else if (currentFixture!.teamScore < currentFixture!.opponentScore) {
            resultColor = AppColors.FixtureLose
        } else {
            resultColor = AppColors.FixtureDraw
        }
        
        // Set main label
        cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.FixtureTeamSize)!
        cell.textLabel?.textColor = resultColor
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = (currentFixture == nil ? "" : currentFixture!.displayOpponent)
        
        // Set detail text
        cell.detailTextLabel?.textColor = resultColor
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.FixtureScoreOrDateTextSize)!
        
        if (currentFixture == nil) {
            cell.detailTextLabel?.text = ""
        } else if (currentFixture!.teamScore == nil || currentFixture!.opponentScore == nil) {
            cell.detailTextLabel?.text = currentFixture!.kickoffTime
        } else {
            cell.detailTextLabel?.text = currentFixture!.score
        }
        
        return cell
    }
    
    override func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        let months = FixtureManager.instance.Months;
        if (months.count <= section) {
            return ""
        }
        
        let fixturesForMonth = FixtureManager.instance.FixturesForMonth(months[section])
        if (fixturesForMonth == nil || fixturesForMonth?.count == 0) {
            return ""
        }
        
        return fixturesForMonth![0].fixtureMonth
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.OtherSectionBackground
        header.textLabel!.textColor = AppColors.OtherSectionText
        header.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherSectionTextSize)!
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
        
        // Set the title
        self.title = "Yeltz Fixture List"
        activity.needsSave = true
        
        self.userActivity = activity;
        self.userActivity?.becomeCurrent()
    }
}
