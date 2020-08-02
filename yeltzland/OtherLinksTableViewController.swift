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
    let leagueTableUrl = URL(string: "https://southern-football-league.co.uk/league-table/Southern%20League%20Premier%20South/2020/2021/P")
    
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
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 4
        } else if (section == 1) {
            return 5
        } else if (section == 2) {
            return 3
        } else if (section == 3) {
            return 1
        } else if (section == 4) {
            return 3
        } else if (section == 5) {
            return 2
        } else if (section == 6) {
            return 4
        }
        
        return 0
    }

    //swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if ((indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 0) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "SettingsCell")
            cell!.selectionStyle = .none
            cell!.accessoryType = .none
            
            let switchView = UISwitch(frame: CGRect.zero)
            switchView.onTintColor = UIColor(named: "blue-tint")
            cell!.accessoryView = switchView
            
            switchView.isOn = self.firebaseNotifications.enabled
            switchView.addTarget(self, action: #selector(OtherLinksTableViewController.notificationsSwitchChanged), for: UIControl.Event.valueChanged)
            
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell!.selectionStyle = .none
            cell!.accessoryType = .disclosureIndicator
        }
        
        if ((indexPath as NSIndexPath).section == 0) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Fixture List"
                let cellImage = UIImage(named: "fixtures")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 1:
                cell!.textLabel?.text = "Latest Score"
                let cellImage = UIImage(named: "latest-score")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 2:
                cell!.textLabel?.text = "Where's the Ground?"
                let cellImage = UIImage(named: "map")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 3:
                cell!.textLabel?.text = "League Table"
                let cellImage = UIImage(named: "table")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 1) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "HTFC on Facebook"
                let cellImage = UIImage(named: "facebook")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 1:
                cell!.textLabel?.text = "Southern League site"
                let cellImage = UIImage(named: "southern-league")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 2:
                cell!.textLabel?.text = "Fantasy Island"
                let cellImage = UIImage(named: "fantasy-island")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 3:
                cell!.textLabel?.text = "Stourbridge Town FC"
                let cellImage = UIImage(named: "stourbridge")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 4:
                cell!.textLabel?.text = "Club Shop"
                let cellImage = UIImage(named: "club-shop")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 2) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Follow Your Instinct"
                let cellImage = UIImage(named: "fyi")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 1:
                cell!.textLabel?.text = "Yeltz Archives"
                let cellImage = UIImage(named: "yeltz-archive")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 2:
                cell!.textLabel?.text = "News Archive (1997-2006)"
                let cellImage = UIImage(named: "news-archive")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 3) {
            cell!.textLabel?.text = "Game time tweets"
            let cellImage = UIImage(named: "game-time")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
            cell!.imageView?.image = cellImage

            cell!.detailTextLabel?.text = "Enable notifications"
        } else if ((indexPath as NSIndexPath).section == 4) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Yeltzland on Amazon Echo"
                let cellImage = UIImage(named: "amazon")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 1:
                cell!.textLabel?.text = "Yeltzland on Google Assistant"
                let cellImage = UIImage(named: "google")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 2:
                    cell!.textLabel?.text = "Add Fixture List to Calendar"
                    let cellImage = UIImage(named: "fixtures")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                    cell!.imageView?.image = cellImage
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 5) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "What's the latest score?"
                let cellImage = UIImage(named: "siri")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            case 1:
                cell!.textLabel?.text = "Who do we play next?"
                let cellImage = UIImage(named: "siri")?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
                cell!.imageView?.image = cellImage
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 6) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Privacy Policy"
                cell!.imageView?.image = nil
            case 1:
                cell!.textLabel?.text = "Icons from icons8.com"
                cell!.imageView?.image = nil
            case 2:
                cell!.textLabel?.text = "More Brave Location Apps"
                cell!.imageView?.image = nil
            case 3:
                cell!.textLabel?.text = ""
                cell!.imageView?.image = nil
                
                let infoDictionary = Bundle.main.infoDictionary!
                let version = infoDictionary["CFBundleShortVersionString"]
                let build = infoDictionary["CFBundleVersion"]
                
                cell!.detailTextLabel?.text = "v\(version!).\(build!)"
                cell?.accessoryType = .none
                cell!.selectionStyle = .none
            default:
                break
            }
        }

        cell!.textLabel?.adjustsFontSizeToFitWidth = true
        cell!.textLabel?.textColor = AppColors.label
        cell!.detailTextLabel?.textColor = AppColors.secondaryLabel
        
        return cell!
    }
    
    //swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).section == 0) {
            if ((indexPath as NSIndexPath).row == 0) {
                let fixtures = FixturesTableViewController(style: .grouped)
                self.navigationController!.pushViewController(fixtures, animated: true)
                return
            } else if ((indexPath as NSIndexPath).row == 1) {
                let latestScore = LatestScoreViewController()
                self.navigationController!.pushViewController(latestScore, animated: true)
                return
            } else if ((indexPath as NSIndexPath).row == 2) {
                let locations = LocationsViewController()
                self.navigationController!.pushViewController(locations, animated: true)
                return
            }
        }
        
        // Add to Siri
        if ((indexPath as NSIndexPath).section == 5) {
            if ((indexPath as NSIndexPath).row == 0) {
                if #available(iOS 13, *) {
                    self.addToSiriAction(intent: ShortcutManager.shared.latestScoreIntent())
                } else {
                    MakeToast.show(self, title: "Sorry!", message: "You need to be running iOS 13 or above to use this shortcut")
                }
                return
            } else if ((indexPath as NSIndexPath).row == 1) {
                if #available(iOS 13, *) {
                    self.addToSiriAction(intent: ShortcutManager.shared.nextGameIntent())
                } else {
                    MakeToast.show(self, title: "Sorry!", message: "You need to be running iOS 13 or above to use this shortcut")
                }
                return
            }
        }
        
        var url: URL? = nil
        
        if ((indexPath as NSIndexPath).section == 0) {
            if ((indexPath as NSIndexPath).row == 3) {
                url = self.leagueTableUrl
            }
        } else if ((indexPath as NSIndexPath).section == 1) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "https://www.facebook.com/HalesowenTown1873")
            case 1:
                url = URL(string: "https://southern-football-league.co.uk")
            case 2:
                url = URL(string: "https://fantasyisland.yeltz.co.uk")
            case 3:
                url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
            case 4:
                url = URL(string: "https://www.yeltzclubshop.com")
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 2) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "https://www.yeltzland.net/followyourinstinct/")
            case 1:
                url = URL(string: "http://www.yeltzarchives.com")
            case 2:
                url = URL(string: "https://www.yeltzland.net/news.html")
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 4) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "https://www.amazon.co.uk/Yeltzland-stuff-about-Halesowen-Town/dp/B01MTJOHBY/")
            case 1:
                url = URL(string: "https://assistant.google.com/services/a/uid/000000a862d84885?hl=en-GB")
            case 2:
                url = URL(string: "https://yeltzland.net/calendar-instructions")
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 6) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "https://bravelocation.com/privacy/yeltzland")
            case 1:
                url = URL(string: "https://icons8.com")
            case 2:
                url = URL(string: "https://bravelocation.com/apps")
            default:
                break
            }
        }
        
        if (url != nil) {
            let svc = SFSafariViewController(url: url!)
            svc.delegate = self
            svc.preferredControlTintColor = UIColor(named: "safari-view-tint")
            
            self.present(svc, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        switch(section) {
        case 0:
            return "Statistics"
        case 1:
             return "Other websites"
        case 2:
            return "Know Your History"
        case 3:
            return "Options"
        case 4:
            return "More from Yeltzland"
        case 5:
            return "Add To Siri"
        case 6:
            return "About"
        default:
            return ""
        }
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
