//
//  OtherLinksTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 05/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import SafariServices
import Font_Awesome_Swift

class OtherLinksTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    let firebaseNotifications = FirebaseNotifications()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation
        self.navigationItem.title = "More"
        
        self.view.backgroundColor = AppColors.OtherBackground
        self.tableView.separatorColor = AppColors.OtherSeparator
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SettingsCell")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
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
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if ((indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 0) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
            cell!.selectionStyle = .none
            cell!.accessoryType = .none
            
            let switchView = UISwitch(frame: CGRect.zero)
            cell!.accessoryView = switchView
            
            switchView.isOn = self.firebaseNotifications.enabled
            switchView.addTarget(self, action: #selector(OtherLinksTableViewController.notificationsSwitchChanged), for: UIControlEvents.valueChanged)
            
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
            cell!.selectionStyle = .default
            cell!.accessoryType = .disclosureIndicator
        }
        
        if ((indexPath as NSIndexPath).section == 0) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Fixture List"
                let cellImage = UIImage(icon: FAType.FACalendar, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "Latest Score"
                let cellImage = UIImage(icon: FAType.FAClockO, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 2:
                cell!.textLabel?.text = "Where's the Ground?"
                let cellImage = UIImage(icon: FAType.FAMapMarker, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
            case 3:
                cell!.textLabel?.text = "League Table"
                let cellImage = UIImage(icon: FAType.FATable, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        }
        else if ((indexPath as NSIndexPath).section == 1) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "HTFC on Facebook"
                let cellImage = UIImage(icon: FAType.FAFacebookSquare, size: CGSize(width: 100, height: 100), textColor: AppColors.Facebook, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "NPL site"
                let cellImage = UIImage(icon: FAType.FASoccerBallO, size: CGSize(width: 100, height: 100), textColor: AppColors.Evostick, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 2:
                cell!.textLabel?.text = "Fantasy Island"
                let cellImage = UIImage(icon: FAType.FAPlane, size: CGSize(width: 100, height: 100), textColor: AppColors.Fantasy, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 3:
                cell!.textLabel?.text = "Stourbridge Town FC"
                let cellImage = UIImage(icon: FAType.FAThumbsODown, size: CGSize(width: 100, height: 100), textColor: AppColors.Stour, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 4:
                cell!.textLabel?.text = "Club Shop"
                let cellImage = UIImage(icon: FAType.FAShoppingCart, size: CGSize(width: 100, height: 100), textColor: AppColors.ClubShop, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 2) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Follow Your Instinct"
                let cellImage = UIImage(icon: FAType.FANewspaperO, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "Yeltz Archives"
                let cellImage = UIImage(icon: FAType.FAArchive, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 2:
                cell!.textLabel?.text = "Yeltzland News Archive"
                let cellImage = UIImage(icon: FAType.FAArchive, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 3) {
            cell!.textLabel?.text = "Game time tweets"
            let cellImage = UIImage(icon: FAType.FATwitter, size: CGSize(width: 100, height: 100), textColor: AppColors.TwitterIcon, backgroundColor: UIColor.clear)

            cell!.imageView?.image = cellImage

            cell!.detailTextLabel?.text = "Enable notifications"
        } else if ((indexPath as NSIndexPath).section == 4) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Yeltzland on Amazon Echo"
                let cellImage = UIImage(icon: FAType.FAAmazon, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "Yeltzland on Google Assistant"
                let cellImage = UIImage(icon: FAType.FAGoogle, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 2:
                    cell!.textLabel?.text = "Add Fixture List to Calendar"
                    let cellImage = UIImage(icon: FAType.FACalendar, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                    cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 5) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Privacy Policy"
                cell!.imageView?.image = nil
                break
            case 1:
                cell!.textLabel?.text = "More Brave Location Apps"
                cell!.imageView?.image = nil
                
                let infoDictionary = Bundle.main.infoDictionary!
                let version = infoDictionary["CFBundleShortVersionString"]
                let build = infoDictionary["CFBundleVersion"]
                
                cell!.detailTextLabel?.text = "v\(version!).\(build!)"
                break
            default:
                break
            }
        }

        // Set fonts
        cell!.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherTextSize)!
        cell!.textLabel?.adjustsFontSizeToFitWidth = true
        cell!.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.OtherDetailTextSize)!
        
        cell!.textLabel?.textColor = AppColors.OtherTextColor
        cell!.detailTextLabel?.textColor = AppColors.OtherDetailColor
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).section == 0) {
            if ((indexPath as NSIndexPath).row == 0) {
                let fixtures = FixturesTableViewController(style: .grouped)
                self.navigationController!.pushViewController(fixtures, animated: true)
                return;
            } else if ((indexPath as NSIndexPath).row == 1) {
                let latestScore = LatestScoreViewController()
                self.navigationController!.pushViewController(latestScore, animated: true)
                return;
            } else if ((indexPath as NSIndexPath).row == 2) {
                let locations = LocationsViewController()
                self.navigationController!.pushViewController(locations, animated: true)
                return;
            }
        }
        
        var url: URL? = nil;
        
        if ((indexPath as NSIndexPath).section == 0) {
            if ((indexPath as NSIndexPath).row == 2) {
                url = URL(string: "http://www.evostikleague.co.uk/match-info/tables")
            }
        } else if ((indexPath as NSIndexPath).section == 1) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "https://www.facebook.com/HalesowenTown1873")
                break
            case 1:
                url = URL(string: "http://www.evostikleague.co.uk")
                break
            case 2:
                url = URL(string: "https://fantasyisland.yeltz.co.uk")
                break
            case 3:
                url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
                break
            case 4:
                url = URL(string: "https://htfc.ace-online.co.uk/catalogue")
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 2) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "http://www.yeltzland.net/followyourinstinct/")
                break
            case 1:
                url = URL(string: "http://www.yeltzarchives.com")
                break
            case 2:
                url = URL(string: "http://www.yeltzland.net/news.html")
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 4) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "https://www.amazon.co.uk/Yeltzland-stuff-about-Halesowen-Town/dp/B01MTJOHBY/")
                break
            case 1:
                url = URL(string: "https://assistant.google.com/services/a/uid/000000a862d84885?hl=en-GB")
                break
            case 2:
                url = URL(string: "https://yeltzland.net/calendar-instructions")
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 5) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "https://bravelocation.com/privacy/yeltzland")
                break
            case 1:
                url = URL(string: "https://bravelocation.com/apps")
                break
            default:
                break
            }
        }
        
        if (url != nil) {
            let svc = SFSafariViewController(url: url!)
            svc.delegate = self
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = AppColors.SafariControl
            }
            
            self.present(svc, animated: true, completion: nil)
        }
    }
    
    override func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        switch(section)
        {
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
            return "About"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.OtherSectionBackground
        header.textLabel!.textColor = AppColors.OtherSectionText
        header.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherSectionTextSize)!
    }
    
    public func openFixtures() {
        print("Opening Fixtures ...")
        
        let indexPath = IndexPath(row: 0, section: 0);
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }
    
    public func openLatestScore() {
        print("Opening Latest Score ...")
        
        let indexPath = IndexPath(row: 1, section: 0);
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }

    // MARK: - Event handler for switch
    @objc func notificationsSwitchChanged(_ sender: AnyObject) {
        let switchControl = sender as! UISwitch
        self.firebaseNotifications.enabled = switchControl.isOn
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func safariViewController(_ controller: SFSafariViewController,
                                activityItemsFor URL: URL,
                                                    title: String?) -> [UIActivity] {
        let chromeActivity = ChromeActivity(currentUrl: URL)
        
        if (chromeActivity.canOpenChrome()) {
            return [chromeActivity];
        }
        
        return [];
    }
}
