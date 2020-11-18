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

    var navigationManager: NavigationManager!
    var selectedIndexPath: IndexPath?
    
    override init(style: UITableView.Style) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.navigationManager = appDelegate.navigationManager
        
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation
        self.navigationItem.title = "More"
        
        self.view.backgroundColor = AppColors.systemBackground
        self.tableView.separatorColor = AppColors.systemBackground
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Reload the table on trait change, in particular to change images on dark mode change
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.navigationManager.moreSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.navigationManager.moreSections[section].elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        let element: NavigationElement = self.navigationManager.moreSections[indexPath.section].elements[indexPath.row]
        
        // Get correct cell type
        switch element.type {
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
        let element: NavigationElement = self.navigationManager.moreSections[indexPath.section].elements[indexPath.row]
        
        switch element.type {
        case .controller(let viewController):
            self.navigationController!.pushViewController(viewController, animated: true)
        case .siri(let intent):
            if #available(iOS 13, *) {
                self.addToSiriAction(intent: intent)
            } else {
                MakeToast.show(self, title: "Sorry!", message: "You need to be running iOS 13 or above to use this shortcut")
            }
        case .link(let url):
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            svc.preferredControlTintColor = UIColor(named: "safari-view-tint")
            
            self.present(svc, animated: true, completion: nil)
        default:
            break
            // NO action on other types
        }
        
        self.selectedIndexPath = indexPath
        
        if let activity = self.navigationManager.userActivity(for: indexPath, delegate: nil, adjustForHeaders: false, moreOnly: true, url: nil) {
            self.navigationManager.lastUserActivity = activity
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.navigationManager.moreSections[section].title
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

// MARK: - Navigation methods
extension OtherLinksTableViewController {
    
    func handleUserActivityNavigation(navigationActivity: NavigationActivity?) {
        if let navActivity = navigationActivity {
            if navActivity.main == false {
                var section = 0
                
                for moreSection in self.navigationManager.moreSections {
                    var row = 0
                    for moreElement in moreSection.elements {
                        if moreElement.id == navActivity.navElementId {
                            let indexPath = IndexPath(row: row, section: section)
                            self.tableView(self.tableView, didSelectRowAt: indexPath)
                        }
                        
                        row += 1
                    }
                    
                    section += 1
                }
            }
        }
    }

    func handleOtherShortcut(_ keyboardShortcut: String) {
        var section = 0
        for otherNavSection in self.navigationManager.moreSections {
            var row = 0
            for otherNavElement in otherNavSection.elements {
                if let key = otherNavElement.keyboardShortcut {
                    if key == keyboardShortcut {
                        let indexPath = IndexPath(row: row, section: section)
                        
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.top)
                        self.tableView(self.tableView, didSelectRowAt: indexPath)
                        return
                    }
                }
                
                row += 1
            }
            
            section += 1
        }
    }
}
