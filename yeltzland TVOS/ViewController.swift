//
//  ViewController.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var fixturesCollectionView: UICollectionView!
    
    let dataSource:TVDataSource = TVDataSource()
    let minutesBetweenUpdates = 5.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotificationWatcher()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler for fixture updates")
    }
    
    fileprivate func setupNotificationWatcher() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fixturesUpdated), name: NSNotification.Name(rawValue: FixtureManager.FixturesNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fixturesUpdated), name: NSNotification.Name(rawValue: GameScoreManager.GameScoreNotification), object: nil)
        print("Setup notification handler for fixture updates")
    }
    
    @objc fileprivate func fixturesUpdated(_ notification: Notification) {
        print("Fixture update message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.dataSource.loadLatestData()
            self.fixturesCollectionView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fixturesCollectionView.delegate = self
        self.fixturesCollectionView.dataSource = self.dataSource
        self.fixturesCollectionView.isScrollEnabled = false
        
        let nib = UINib(nibName: "TVFixtureCollectionCell", bundle: nil)
        self.fixturesCollectionView.register(nib, forCellWithReuseIdentifier: "TVFixtureCollectionCell")
        
        self.view.backgroundColor = AppColors.TVBackground
        self.fixturesCollectionView.backgroundColor = AppColors.TVBackground
        
        // Setup timer to refresh info
        _ = Timer.scheduledTimer(timeInterval: minutesBetweenUpdates * 60, target: self, selector: #selector(self.fetchLatestData), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async() {
            self.moveToNextFixture()
        }
    }
    
    @objc func fetchLatestData() {
        print("Fetching latest data ...")

        // Update the fixture and game score caches
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 400.0, height: 300.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return IndexPath(row: self.dataSource.indexOfFirstFixture(), section: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                        with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedIndexPath != nil && !collectionView.isScrollEnabled) {
            collectionView.scrollToItem(at: context.nextFocusedIndexPath!, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    override weak var preferredFocusedView: UIView? {
        return self.fixturesCollectionView
    }
    
    func moveToNextFixture() {
        let nextFixturePath = IndexPath(row: self.dataSource.indexOfFirstFixture(), section: 0)
        self.fixturesCollectionView.scrollToItem(at: nextFixturePath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
}

