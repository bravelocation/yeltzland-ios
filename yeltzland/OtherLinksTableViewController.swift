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

    let azureNotifications = AzureNotifications()
    
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
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 3
        } else if (section == 1) {
            return 4
        } else if (section == 2) {
            return 2
        } else if (section == 3) {
            return 1
        } else if (section == 4) {
            return 1
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
            
            switchView.isOn = self.azureNotifications.enabled
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
                let cellImage = UIImage(icon: FAType.faCalendar, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "Where's the Ground?"
                let cellImage = UIImage(icon: FAType.faMapMarker, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
            case 2:
                cell!.textLabel?.text = "League Table"
                let cellImage = UIImage(icon: FAType.faTable, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clear)
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
                let cellImage = UIImage(icon: FAType.faFacebookSquare, size: CGSize(width: 100, height: 100), textColor: AppColors.Facebook, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "NPL site"
                let cellImage = UIImage(icon: FAType.faSoccerBallO, size: CGSize(width: 100, height: 100), textColor: AppColors.Evostick, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 2:
                cell!.textLabel?.text = "Fantasy Island"
                let cellImage = UIImage(icon: FAType.faPlane, size: CGSize(width: 100, height: 100), textColor: AppColors.Fantasy, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 3:
                cell!.textLabel?.text = "Stourbridge Town FC"
                let cellImage = UIImage(icon: FAType.faThumbsODown, size: CGSize(width: 100, height: 100), textColor: AppColors.Stour, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 2) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                cell!.textLabel?.text = "Yeltz Archives"
                let cellImage = UIImage(icon: FAType.faArchive, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "Yeltzland News Archive"
                let cellImage = UIImage(icon: FAType.faNewspaperO, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clear)
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 3) {
            cell!.textLabel?.text = "Game time tweets"
            let cellImage = UIImage(icon: FAType.faTwitter, size: CGSize(width: 100, height: 100), textColor: AppColors.TwitterIcon, backgroundColor: UIColor.clear)

            cell!.imageView?.image = cellImage

            cell!.detailTextLabel?.text = "Enable notifications"
        } else if ((indexPath as NSIndexPath).section == 4) {
            cell!.textLabel?.text = "More Brave Location Apps"
            let cellImage = UIImage(icon: FAType.faMapMarker, size: CGSize(width: 100, height: 100), textColor: AppColors.BraveLocation, backgroundColor: UIColor.clear)
            cell!.imageView?.image = cellImage
            
            let infoDictionary = Bundle.main.infoDictionary!
            let version = infoDictionary["CFBundleShortVersionString"]
            let build = infoDictionary["CFBundleVersion"]
            
            cell!.detailTextLabel?.text = "v\(version!).\(build!)"
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
                url = URL(string: "https://www.facebook.com/halesowentownfc/")
                break
            case 1:
                url = URL(string: "http://www.evostikleague.co.uk")
                break
            case 2:
                url = URL(string: "http://yeltz.co.uk/fantasyisland")
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 2) {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                url = URL(string: "http://www.yeltzarchives.com")
                break
            case 1:
                url = URL(string: "http://www.yeltzland.net/news.html")
                break
            default:
                break
            }
        } else if ((indexPath as NSIndexPath).section == 4) {
            url = URL(string: "https://bravelocation.com/apps")
        }
        
        if (url != nil) {
            let svc = SFSafariViewController(url: url!)
            svc.delegate = self
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = AppColors.SafariControl
                svc.preferredBarTintColor = AppColors.SafariBar
            }
            
            self.present(svc, animated: true, completion: nil)
        } else if ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 3) {
            let alert = UIAlertController(title: "Really?", message: "Computer says no", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
    
    // MARK: - Event handler for switch
    func notificationsSwitchChanged(_ sender: AnyObject) {
        let switchControl = sender as! UISwitch
        self.azureNotifications.enabled = switchControl.isOn
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
