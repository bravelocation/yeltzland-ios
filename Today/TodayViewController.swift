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
    
    private let sectionInsets: UIEdgeInsets =  UIEdgeInsets.init(top: 8.0, left: 8.0, bottom: 0.0, right: 8.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timelineManager = TimelineManager(fixtureManager: FixtureManager.shared, gameScoreManager: GameScoreManager.shared)
        self.timelineEntries = timelineManager.timelineEntries
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact
        self.collectionView.register(UINib(nibName: TodayViewController.cellReuseIdentifier, bundle: .main), forCellWithReuseIdentifier: TodayViewController.cellReuseIdentifier)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = true
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return self.sectionInsets
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
    
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
      let url = URL(string: "yeltzland://")
      print("Opening app")
      self.extensionContext?.open(url!, completionHandler: nil)

      return false
    }
}

// MARK: - Collection View Flow Layout Delegate
extension TodayViewController: UICollectionViewDelegateFlowLayout {
    fileprivate var itemsPerRow: CGFloat {
        return 2
    }

    fileprivate var interItemSpace: CGFloat {
        return 4.0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionPadding = sectionInsets.left * (itemsPerRow + 1)
        let interitemPadding = max(0.0, itemsPerRow - 1) * interItemSpace
        let availableWidth = collectionView.bounds.width - sectionPadding - interitemPadding
        let widthPerItem = availableWidth / itemsPerRow
        
        let availableHeight = collectionView.bounds.height - sectionPadding

        return CGSize(width: widthPerItem, height: availableHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
