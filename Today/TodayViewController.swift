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
    
    let CellRowHeight:CGFloat = 22.0
    var inExpandedMode:Bool = false
    let gameSettings = GameSettings.instance
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.setupNotificationWatchers()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatchers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.Expanded
        } else {
            // Fallback on earlier versions
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.view.backgroundColor = AppColors.TodayBackground
        self.tableView.separatorColor = AppColors.TodaySeparator
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Fetch latest fixtures
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
        
        var rowCount:CGFloat = 5.0
        if (self.inExpandedMode) {
            rowCount = 9.0
        }
        
        self.preferredContentSize = CGSizeMake(0.0, self.CellRowHeight * rowCount)
        completionHandler(NCUpdateResult.NewData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.Compact) {
            self.preferredContentSize = maxSize
            self.inExpandedMode = false
        }
        else {
            self.preferredContentSize = CGSize(width: maxSize.width, height: self.CellRowHeight * 9)
            self.inExpandedMode = true
        }
        
        self.tableView.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler for fixture updates in today view")
    }
    
    private func setupNotificationWatchers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TodayViewController.fixturesUpdated), name: BaseSettings.SettingsUpdateNotification, object: nil)
        print("Setup notification handlers for fixture or score updates in today view")
    }
    
    @objc private func fixturesUpdated(notification: NSNotification) {
        print("Fixture update message received in today view")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.gameSettings.gameScoreForCurrentGame) {
            return 3
        }
        
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return 1
        case 1:
            if (self.gameSettings.gameScoreForCurrentGame) {
                return 1
            } else if (self.inExpandedMode) {
                return 6
            } else {
                return 2
            }
        case 2:
            if (self.inExpandedMode) {
                return 3
            } else {
                return 0
            }

        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "FixtureTodayCell")
       
        // Figure out data to show
        let nextFixtures = FixtureManager.instance.GetNextFixtures(6)
        var opponent: String = ""
        var gameDetails = ""
        
        if (indexPath.section == 0) {
            opponent = self.gameSettings.displayLastOpponent
            gameDetails = self.gameSettings.lastScore
        } else if (indexPath.section == 1) {
            if (self.gameSettings.gameScoreForCurrentGame) {
                opponent = self.gameSettings.displayNextOpponent
                gameDetails = self.gameSettings.currentScore
            } else if (nextFixtures.count > indexPath.row){
                opponent = nextFixtures[indexPath.row].displayOpponent
                gameDetails = indexPath.row == 0 ? self.gameSettings.nextKickoffTime : nextFixtures[indexPath.row].fullKickoffTime
            }
        } else if (indexPath.section == 2) {
            // Need to ignore the current game
            if (nextFixtures.count > indexPath.row + 1){
                opponent = nextFixtures[indexPath.row + 1].displayOpponent
                gameDetails = nextFixtures[indexPath.row + 1].fullKickoffTime
            }
        }
                
        if (opponent.characters.count > 0) {
            cell.textLabel?.text = opponent
            cell.detailTextLabel?.text = gameDetails
        } else {
            cell.textLabel?.text = "  None"
            cell.detailTextLabel?.text = ""
        }

        // Set colors
        cell.selectionStyle = .None
        cell.accessoryType = .None
        cell.backgroundColor = AppColors.TodayBackground
        cell.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)

        cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.TodayTextSize)!
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.TodayFootnoteSize)!
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        cell.textLabel?.textColor = AppColors.TodayText
        cell.detailTextLabel?.textColor = AppColors.TodayText
            
        if (indexPath.section == 0 && opponent.characters.count > 0) {
            if (AppColors.isIos10AndAbove) {
                let teamScore = self.gameSettings.lastGameYeltzScore
                let opponentScore  = self.gameSettings.lastGameOpponentScore
                
                var resultColor = AppColors.TodayText
                
                if (teamScore > opponentScore) {
                    resultColor = AppColors.FixtureWin
                } else if (teamScore < opponentScore) {
                    resultColor = AppColors.FixtureLose
                } else {
                    resultColor = AppColors.FixtureDraw
                }
                
                cell.textLabel?.textColor = resultColor
                cell.detailTextLabel?.textColor = resultColor
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = NSURL(string:"yeltzland://")
        print("Opening app")
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.TodayBackground
        header.textLabel!.textColor = AppColors.OtherSectionText
        header.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherSectionTextSize)!
        
        switch section {
        case 0:
            header.textLabel?.text = " Last game"
        case 1:
            if (self.gameSettings.gameScoreForCurrentGame) {
                header.textLabel?.text = " Current score"
            } else {
                header.textLabel?.text = " Next fixtures"
            }
        case 2:
            if (self.inExpandedMode) {
                header.textLabel?.text = " Next fixtures"
            } else {
                header.textLabel?.text = ""
            }
        default:
             header.textLabel?.text = ""
        }
    }

    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.contentView.backgroundColor = AppColors.TodayBackground
        footer.textLabel!.textColor = AppColors.TodayText
        footer.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherDetailTextSize)!
        
        switch section {
        case 1:
            if (self.gameSettings.gameScoreForCurrentGame) {
                footer.textLabel?.text = "  (*best guess from Twitter)"
            } else {
                footer.textLabel?.text = ""
            }
        default:
            footer.textLabel?.text = ""
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.CellRowHeight
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 1 && self.gameSettings.gameScoreForCurrentGame) {
            return 20.0
        }
        
        return 0.0
    }
}
