//
//  TodayDataSource.swift
//  yeltzland
//
//  Created by John Pollard on 28/05/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class TodayDataSource: NSObject, UITableViewDataSource {
    
    private var timelineManager: TimelineManager
    private var timelineEntries: [TimelineEntry]
    
    override init() {
        // TODO: Don't forget to switch this back to the real provider before release
        //self.timelineManager = TimelineManager(fixtureManager: FixtureManager.shared, gameScoreManager: GameScoreManager.shared)
        self.timelineManager = TimelineManager(fixtureManager: MockFixtureManager(), gameScoreManager: MockGameScoreManager())
        
        self.timelineEntries = self.timelineManager.timelineEntries
        
        super.init()
    }
    
    func reloadData() {
        self.timelineManager.reloadData()
    }
    
    private func getFixtureDisplayColor(_ fixture: TimelineEntry?) -> UIColor {
        var resultColor = AppColors.label
        
        guard let fixture = fixture else {
            return resultColor
        }
        
        let teamScore = fixture.teamScore
        let opponentScore  = fixture.opponentScore
        
        if (teamScore != nil && opponentScore != nil) {
            if (teamScore! > opponentScore!) {
                resultColor = UIColor(named: "fixture-win")!
            } else if (teamScore! < opponentScore!) {
                resultColor = UIColor(named: "fixture-lose")!
            } else {
                resultColor = UIColor(named: "fixture-draw")!
            }
        }
        
        return resultColor
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "FixtureTodayCell")
        
        // Figure out data to show
        var entry: TimelineEntry?
        
        if (self.timelineEntries.count >= indexPath.row) {
            entry = self.timelineEntries[indexPath.row]
        }
        
        if let entry = entry {
            cell.textLabel?.text = entry.opponent
            switch (entry.status) {
            case .result:
                cell.detailTextLabel?.text = "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)"
            case .inProgress:
                cell.detailTextLabel?.text = "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)*"
            case .fixture:
                cell.detailTextLabel?.text = "\(entry.date)"
            }
        }
        
        // Set colors
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.separatorInset = UIEdgeInsets.init(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        let resultColor = self.getFixtureDisplayColor(entry)
        cell.textLabel?.textColor = resultColor
        cell.detailTextLabel?.textColor = resultColor
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timelineEntries.count
    }
}
