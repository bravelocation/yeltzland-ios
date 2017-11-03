//
//  TodayDataSource.swift
//  yeltzland
//
//  Created by John Pollard on 28/05/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class TodayDataSource: NSObject, UITableViewDataSource {

    let gameSettings = GameSettings.instance

    private var lastGames = Array<TodayDataItem>()
    private var nextGames = Array<TodayDataItem>()
    private var currentScores = Array<TodayDataItem>()
    
    override init() {
        super.init();
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        // Get last game details
        let opponent = self.gameSettings.displayLastOpponent

        self.lastGames.removeAll()

        if (opponent.count > 0) {
            let teamScore = self.gameSettings.lastGameYeltzScore
            let opponentScore  = self.gameSettings.lastGameOpponentScore
            
            var resultColor = AppColors.TodayText
            
            if (teamScore != nil && opponentScore != nil) {
                if (teamScore! > opponentScore!) {
                    resultColor = AppColors.FixtureWin
                } else if (teamScore! < opponentScore!) {
                    resultColor = AppColors.FixtureLose
                } else {
                    resultColor = AppColors.FixtureDraw
                }
            }

            self.lastGames.append(TodayDataItem(opponent: self.gameSettings.displayLastOpponent, scoreOrDate: self.gameSettings.lastScore, color:resultColor))
        }
        
        // Get current score if applicable
        self.currentScores.removeAll()
        if (self.gameSettings.gameScoreForCurrentGame) {
            self.currentScores.append(TodayDataItem(opponent: self.gameSettings.displayNextOpponent, scoreOrDate: self.gameSettings.currentScore))
        }
        
        // How many fixtures to get?
        var fixturesNeeded = 6
        if (self.currentScores.count > 0) {
            fixturesNeeded = 4
        }
        
        // Get next games
        self.nextGames.removeAll()
        
        var i = 0
        for fixture in FixtureManager.instance.GetNextFixtures(fixturesNeeded) {
            
            // Only add first fixture if no current game
            if (i > 0 || self.currentScores.count == 0) {
                let fixtureData = TodayDataItem(opponent: fixture.displayOpponent, scoreOrDate: fixture.displayKickoffTime)
                self.nextGames.append(fixtureData)
            }
            
            i = i + 1
        }
    }
    
    func headerText(section:Int) -> String {
        var firstSectionHeader = ""
        var secondSectionHeader = ""
        var thirdSectionHeader = ""

        if (self.lastGames.count > 0) {
            firstSectionHeader = " Last game"
        }
        
        if (self.currentScores.count > 0) {
            if (firstSectionHeader.count == 0) {
                firstSectionHeader = " Current score"
            } else {
                secondSectionHeader = " Current score"
            }
        }
        
        if (self.nextGames.count > 0) {
            if (firstSectionHeader.count == 0) {
                firstSectionHeader = " Next fixtures"
            } else if (secondSectionHeader.count == 0){
                secondSectionHeader = " Next fixtures"
            } else {
                thirdSectionHeader = " Next fixtures"
            }
        }
        
        if (section == 0) {
            return firstSectionHeader
        } else if (section == 1) {
            return secondSectionHeader
        } else {
            return thirdSectionHeader
        }
    }
    
    func footerText(section:Int) -> String {
        // Only show footer for current score
        if (self.currentScores.count > 0) {
            if ((self.lastGames.count > 0) && section == 1) {
                return "  (*best guess from Twitter)"
            } else if ((self.lastGames.count == 0) && section == 0) {
                return "  (*best guess from Twitter)"
            }
        }
        
        return ""
    }
    
    private func dataItemsForSection(section:Int) -> Array<TodayDataItem>? {
        var firstSection:Array<TodayDataItem>? = nil
        var secondSection:Array<TodayDataItem>? = nil
        var thirdSection:Array<TodayDataItem>? = nil
        
        if (self.lastGames.count > 0) {
            firstSection = self.lastGames
        }
        
        if (self.currentScores.count > 0) {
            if (firstSection == nil) {
                firstSection = self.currentScores
            } else {
                secondSection = self.currentScores
            }
        }
        
        if (self.nextGames.count > 0) {
            if (firstSection == nil) {
                firstSection = self.nextGames
            } else if (secondSection == nil){
                secondSection = self.nextGames
            } else {
                thirdSection = self.nextGames
            }
        }
       
        if (section == 0) {
            return firstSection
        } else if (section == 1) {
            return secondSection
        } else {
            return thirdSection
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "FixtureTodayCell")
        
        // Figure out data to show
        var opponent: String = ""
        var gameDetails = ""
        var resultColor = AppColors.TodayText
        
        if let dataItems = self.dataItemsForSection(section: indexPath.section) {
            if (dataItems.count >= indexPath.row) {
                let dataItem = dataItems[indexPath.row]
                opponent = dataItem.opponent
                gameDetails = dataItem.scoreOrDate
                resultColor = dataItem.resultColor
            }
        }
        
        cell.textLabel?.text = opponent
        cell.detailTextLabel?.text = gameDetails
        
        // Set colors
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.backgroundColor = AppColors.TodayBackground
        cell.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)
        
        cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.TodayTextSize)!
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.TodayFootnoteSize)!
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        cell.textLabel?.textColor = resultColor
        cell.detailTextLabel?.textColor = resultColor
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = 0
        
        if (self.lastGames.count > 0) {
           sectionCount = sectionCount + 1
        }

        if (self.nextGames.count > 0) {
            sectionCount = sectionCount + 1
        }
        
        if (self.currentScores.count > 0) {
            sectionCount = sectionCount + 1
        }
        
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let dataItems = self.dataItemsForSection(section: section)
        if (dataItems == nil) {
            return 0
        }
        
        return dataItems!.count
    }
}
