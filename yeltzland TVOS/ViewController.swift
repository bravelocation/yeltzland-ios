//
//  ViewController.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fixturesCollectionView: UICollectionView!
    @IBOutlet weak var tweetsCollectionView: UICollectionView!
    
    var dataTimer: Timer? = nil
    
    let fixturesDataSource: TVFixturesDataSource = TVFixturesDataSource()
    let tweetsDataSource: TwitterDataSource = TwitterDataSource()

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
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fixturesUpdated), name: NSNotification.Name(rawValue: FixtureManager.shared.notificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fixturesUpdated), name: NSNotification.Name(rawValue: GameScoreManager.shared.notificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.tweetsUpdated), name: NSNotification.Name(rawValue: TwitterDataProvider.TweetsNotification), object: nil)
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
        
        self.view.backgroundColor = UIColor.black
        self.titleLabel.textColor = UIColor(named: "light-blue")

        // Setup fixtures
        self.fixturesCollectionView.delegate = self
        self.fixturesCollectionView.dataSource = self.fixturesDataSource
        self.fixturesCollectionView.isScrollEnabled = false
        self.fixturesCollectionView.backgroundColor = UIColor.black

        self.fixturesCollectionView.register(UINib(nibName: "TVFixtureCollectionCell", bundle: nil),
                                             forCellWithReuseIdentifier: "TVFixtureCollectionCell")
        
        // Setup tweets
        self.tweetsCollectionView.delegate = self
        self.tweetsCollectionView.dataSource = self.tweetsDataSource
        self.tweetsCollectionView.isScrollEnabled = false
        self.tweetsCollectionView.backgroundColor = UIColor.black
        
        self.tweetsCollectionView.register(UINib(nibName: "TVTwitterCollectionCell", bundle: nil),
                                           forCellWithReuseIdentifier: "TVTwitterCollectionCell")

        // Setup timer to refresh info
        self.dataTimer = Timer.scheduledTimer(timeInterval: minutesBetweenUpdates * 60, target: self, selector: #selector(self.fetchLatestData), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async() {
            self.moveToNextFixture()
        }
    }
    
    @objc func fetchLatestData() {
        print("*** Fetching latest data ...")

        // Update the fixture and game score caches
        FixtureManager.shared.fetchLatestData(completion: nil)
        GameScoreManager.shared.fetchLatestData(completion: nil)
        
        // Update the tweets
        self.tweetsDataSource.loadLatestData()
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
            collectionView.scrollToItem(at: context.nextFocusedIndexPath!, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
        
        // Set the border on selected item, and unset on last item
        if let previousIndexPath = context.previouslyFocusedIndexPath,
            let cell = collectionView.cellForItem(at: previousIndexPath) {
            cell.contentView.layer.borderWidth = 0.0
        }
        
        if let indexPath = context.nextFocusedIndexPath,
            let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.layer.borderWidth = 4.0
            cell.contentView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    override weak var preferredFocusedView: UIView? {
        return self.fixturesCollectionView
    }
    
    func moveToNextFixture() {
        let nextFixturePath = IndexPath(row: self.fixturesDataSource.indexOfFirstFixture(), section: 0)
        
        if (nextFixturePath.row > 0) {
            self.fixturesCollectionView.scrollToItem(at: nextFixturePath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
}
