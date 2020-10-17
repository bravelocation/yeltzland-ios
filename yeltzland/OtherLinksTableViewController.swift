//
//  OtherLinksTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 05/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import SafariServices
import Intents
import IntentsUI

class OtherLinksTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    let firebaseNotifications = FirebaseNotifications()
    let navigationData = NavigationManager().moreSections
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation
        self.navigationItem.title = "More"
        
        self.view.backgroundColor = AppColors.systemBackground
        self.tableView.separatorColor = AppColors.systemBackground
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SettingsCell")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Reload the table on trait change, in particular to change images on dark mode change
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return navigationData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navigationData[section].elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        let element: NavigationElement = navigationData[indexPath.section].elements[indexPath.row]
        
        // Get correct cell type
        switch element.type {
        case .notificationsSettings:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "SettingsCell")
            cell!.selectionStyle = .none
            cell!.accessoryType = .none
            
            let switchView = UISwitch(frame: CGRect.zero)
            switchView.onTintColor = UIColor(named: "blue-tint")
            cell!.accessoryView = switchView
            
            switchView.isOn = self.firebaseNotifications.enabled
            switchView.addTarget(self, action: #selector(OtherLinksTableViewController.notificationsSwitchChanged), for: UIControl.Event.valueChanged)
        case .info:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell!.selectionStyle = .none
            cell!.accessoryType = .none
        default:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell!.selectionStyle = .none
            cell!.accessoryType = .disclosureIndicator
        }
        
        cell!.textLabel?.text = element.title
        cell!.detailTextLabel?.text = element.subtitle
        if let imageName = element.imageName {
            let cellImage = UIImage(named: imageName)?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
            cell!.imageView?.image = cellImage
        }

        cell!.textLabel?.adjustsFontSizeToFitWidth = true
        cell!.textLabel?.textColor = AppColors.label
        cell!.detailTextLabel?.textColor = AppColors.secondaryLabel
        if #available(iOS 13.0, *) {
            cell!.backgroundColor = .systemBackground
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element: NavigationElement = navigationData[indexPath.section].elements[indexPath.row]
        
        switch element.type {
        case .controller(let viewController):
            self.navigationController!.pushViewController(viewController, animated: true)
        case .siri(let intent):
            if #available(iOS 13, *) {
                self.addToSiriAction(intent: intent)
            } else {
                MakeToast.show(self, title: "Sorry!", message: "You need to be running iOS 13 or above to use this shortcut")
            }
            return
        case .link(let url):
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            svc.preferredControlTintColor = UIColor(named: "safari-view-tint")
            
            self.present(svc, animated: true, completion: nil)
        default:
            return
            // NO action on other types
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return navigationData[section].title
    }
    
    public func openFixtures() {
        print("Opening Fixtures ...")
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.top)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }
    
    public func openLatestScore() {
        print("Opening Latest Score ...")
        
        let indexPath = IndexPath(row: 1, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.top)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }
    
    public func openLocations() {
        print("Opening Where's The Ground ...")
        
        let indexPath = IndexPath(row: 2, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.top)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }
    
    public func openLeagueTable() {
        print("Opening League Table ...")
        
        let indexPath = IndexPath(row: 3, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.top)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }

    // MARK: - Event handler for switch
    @objc func notificationsSwitchChanged(_ sender: AnyObject) {
        let switchControl = sender as! UISwitch
        self.firebaseNotifications.enabled = switchControl.isOn
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func safariViewController(_ controller: SFSafariViewController,
                              activityItemsFor URL: URL,
                              title: String?) -> [UIActivity] {
        let chromeActivity = ChromeActivity(currentUrl: URL)
        
        if (chromeActivity.canOpenChrome()) {
            return [chromeActivity]
        }
        
        return []
    }
}

extension OtherLinksTableViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addToSiriAction(intent: INIntent) {
        if let shortcut = INShortcut(intent: intent) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.modalPresentationStyle = .formSheet
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - INUIAddVoiceShortcutViewControllerDelegate
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print("Added shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        print("Cancelled shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
}
