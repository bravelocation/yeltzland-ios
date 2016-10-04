//
//  FixturesTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

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
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler for fixture updates")
    }
    
    private func setupNotificationWatcher() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FixturesTableViewController.fixturesUpdated), name: FixtureManager.FixturesNotification, object: nil)
        print("Setup notification handler for fixture updates")
    }
    
    @objc private func fixturesUpdated(notification: NSNotification) {
        print("Fixture update message received")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            
            let currentMonthIndexPath = NSIndexPath(forRow: 0, inSection: self.currentMonthSection())
            self.tableView.scrollToRowAtIndexPath(currentMonthIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        })
    }
    
    private func currentMonthSection() -> Int {
        var monthIndex = 0

        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMM"
        let currentMonth = formatter.stringFromDate(now)
        
        for month in FixtureManager.instance.Months {
            if (month == currentMonth) {
                return monthIndex
            }
            
            monthIndex = monthIndex + 1
        }
        
        // No match found, so just start at the top
        return 0
    }
    
    func reloadButtonTouchUp() {
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
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "FixtureCell")
        
        // Setup refresh button
        self.reloadButton = UIBarButtonItem(
            title: "Reload",
            style: .Plain,
            target: self,
            action: #selector(FixturesTableViewController.reloadButtonTouchUp)
        )
        self.reloadButton.FAIcon = FAType.FARotateRight
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        self.navigationController?.navigationBar.tintColor = AppColors.NavBarTintColor
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FixtureManager.instance.Months.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "FixtureCell")

        // Find the fixture
        var currentFixture:Fixture? = nil
        let months = FixtureManager.instance.Months;
        
        if (months.count > indexPath.section) {
            let fixturesForMonth = FixtureManager.instance.FixturesForMonth(months[indexPath.section])
        
            if (fixturesForMonth != nil && fixturesForMonth?.count > indexPath.row) {
                currentFixture = fixturesForMonth![indexPath.row]
            }
        }

        cell.selectionStyle = .None
        cell.accessoryType = .None
        
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
    
    override func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String
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
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.OtherSectionBackground
        header.textLabel!.textColor = AppColors.OtherSectionText
        header.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherSectionTextSize)!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 33.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}
