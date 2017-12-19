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
    @IBOutlet weak var tweetsCollectionView: UICollectionView!
    
    let fixturesDataSource:TVFixturesDataSource = TVFixturesDataSource()
    let tweetsDataSource:TwitterDataSource = TwitterDataSource()

    let minutesBetweenUpdates = 5.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotificationWatcher()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler for updates")
    }
    
    fileprivate func setupNotificationWatcher() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fixturesUpdated), name: NSNotification.Name(rawValue: FixtureManager.FixturesNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fixturesUpdated), name: NSNotification.Name(rawValue: GameScoreManager.GameScoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.tweetsUpdated), name: NSNotification.Name(rawValue: TwitterDataSource.TweetsNotification), object: nil)
        print("Setup notification handler for updates")
    }
    
    @objc fileprivate func fixturesUpdated(_ notification: Notification) {
        print("Fixture update message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.fixturesDataSource.loadLatestData()
            self.fixturesCollectionView.reloadData()
        })
    }
    
    @objc fileprivate func tweetsUpdated(_ notification: Notification) {
        print("Tweets update message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.tweetsCollectionView.reloadData()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AppColors.TVBackground
        
        // Setup fixtures
        self.fixturesCollectionView.delegate = self
        self.fixturesCollectionView.dataSource = self.fixturesDataSource
        self.fixturesCollectionView.isScrollEnabled = false
        self.fixturesCollectionView.backgroundColor = AppColors.TVBackground

        self.fixturesCollectionView.register(UINib(nibName: "TVFixtureCollectionCell", bundle: nil),
                                             forCellWithReuseIdentifier: "TVFixtureCollectionCell")
        
        // Setup tweets
        self.tweetsCollectionView.delegate = self
        self.tweetsCollectionView.dataSource = self.tweetsDataSource
        self.tweetsCollectionView.isScrollEnabled = false
        self.tweetsCollectionView.backgroundColor = AppColors.TVBackground
        
        self.tweetsCollectionView.register(UINib(nibName: "TVTwitterCollectionCell", bundle: nil),
                                           forCellWithReuseIdentifier: "TVTwitterCollectionCell")

        
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
        
        // Update the tweets
        self.tweetsDataSource.loadLatestData()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == self.fixturesCollectionView) {
            return CGSize(width: 400.0, height: 300.0)
        } else {
            return CGSize(width: 800.0, height: 400.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        if (collectionView == self.fixturesCollectionView) {
            return IndexPath(row: self.fixturesDataSource.indexOfFirstFixture(), section: 0)
        } else {
            return IndexPath(row: 0, section: 0)
        }
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
        let nextFixturePath = IndexPath(row: self.fixturesDataSource.indexOfFirstFixture(), section: 0)
        self.fixturesCollectionView.scrollToItem(at: nextFixturePath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
}

