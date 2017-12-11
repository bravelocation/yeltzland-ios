//
//  ViewController.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var fixturesTableView: UITableView!
    
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
            self.fixturesTableView.reloadData()
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fixturesTableView.delegate = self
        self.fixturesTableView.dataSource = self.dataSource
        
        self.view.backgroundColor = AppColors.TVBackground
        
        // Setup timer to refresh info
        _ = Timer.scheduledTimer(timeInterval: minutesBetweenUpdates * 60, target: self, selector: #selector(self.fetchLatestData), userInfo: nil, repeats: true)
    }
    
    @objc func fetchLatestData() {
        print("Fetching latest data ...")

        // Update the fixture and game score caches
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.TVBackground
        header.textLabel!.textColor = AppColors.TVHeaderText
        header.textLabel!.font = UIFont.preferredFont(forTextStyle: .headline)
        header.textLabel?.text = self.dataSource.headerText(section: section)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.contentView.backgroundColor = AppColors.TVBackground
        footer.textLabel!.textColor = AppColors.TVText
        footer.textLabel!.font = UIFont.preferredFont(forTextStyle: .headline)
        footer.textLabel?.text = self.dataSource.footerText(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let footerText = self.dataSource.footerText(section: section)
        
        if (footerText.count > 0) {
            return 66.0
        }
        
        return 0.0
    }
}

