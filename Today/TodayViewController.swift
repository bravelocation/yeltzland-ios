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
    
    let cellRowHeight: CGFloat = 22.0
    var inExpandedMode: Bool = false
    let dataSource = TodayDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        } else {
            // Fallback on earlier versions
        }
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        
        self.view.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear
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
        
        var rowCount: CGFloat = 5.0
        if (self.inExpandedMode) {
            rowCount = 9.0
        }
        
        self.preferredContentSize = CGSize(width: 0.0, height: self.cellRowHeight * rowCount)
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
            self.inExpandedMode = false
        } else {
            self.preferredContentSize = CGSize(width: maxSize.width, height: self.cellRowHeight * 9)
            self.inExpandedMode = true
        }
        
        self.tableView.reloadData()
    }
    
    func fixturesUpdated() {
        print("Fixture update message received in today view")
        DispatchQueue.main.async(execute: { () -> Void in
            self.dataSource.loadLatestData()
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: "yeltzland://")
        print("Opening app")
        self.extensionContext?.open(url!, completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel!.textColor = AppColors.label
            headerView.textLabel!.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.TodayTextSize)!
            headerView.textLabel?.text = self.dataSource.headerText(section: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel!.textColor = AppColors.label
            footerView.textLabel!.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.TodayFootnoteSize)!
            footerView.textLabel?.text = self.dataSource.footerText(section: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellRowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.cellRowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let footerText = self.dataSource.footerText(section: section)
        
        if (footerText.count > 0) {
            return self.cellRowHeight
        }
        
        return 0.0
    }
}
