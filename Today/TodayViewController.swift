//
//  TodayViewController.swift
//  Today
//
//  Created by John Pollard on 27/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UICollectionViewController, NCWidgetProviding {
    
    private var timelineManager: TimelineManager!
    private var timelineEntries: [TimelineEntry] = []
    
    static var cellReuseIdentifier = "TodayFixtureCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Don't forget to switch this back to the real provider before release
        //self.timelineManager = TimelineManager(fixtureManager: FixtureManager.shared, gameScoreManager: GameScoreManager.shared)
        self.timelineManager = TimelineManager(fixtureManager: MockFixtureManager(), gameScoreManager: MockGameScoreManager())
        self.timelineEntries = timelineManager.timelineEntries
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact
        self.collectionView.register(UINib(nibName: TodayViewController.cellReuseIdentifier, bundle: .main), forCellWithReuseIdentifier: TodayViewController.cellReuseIdentifier)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
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
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func fixturesUpdated() {
        print("Fixture update message received in today view")
        DispatchQueue.main.async(execute: { () -> Void in
            self.timelineManager.reloadData()
            self.collectionView.reloadData()
        })
    }
    
    // MARK: - Collection view data source
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timelineEntries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayViewController.cellReuseIdentifier, for: indexPath) as! TodayFixtureCollectionViewCell
        
        // Figure out data to show
        var entry: TimelineEntry?
        
        if (self.timelineEntries.count >= indexPath.row) {
            entry = self.timelineEntries[indexPath.row]
        }
        
        if let entry = entry {
            cell.updateData(entry)
        }
        
        // Configure the cell
        return cell
    }

    // MARK: - Table view delegate
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: "yeltzland://")
        print("Opening app")
        self.extensionContext?.open(url!, completionHandler: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellRowHeight
    }
 */
}
