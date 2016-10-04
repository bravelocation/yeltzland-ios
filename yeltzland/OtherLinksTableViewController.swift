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
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SettingsCell")
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if (indexPath.section == 3 && indexPath.row == 0) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
            cell!.selectionStyle = .None
            cell!.accessoryType = .None
            
            let switchView = UISwitch(frame: CGRectZero)
            cell!.accessoryView = switchView
            
            switchView.on = self.azureNotifications.enabled
            switchView.addTarget(self, action: #selector(OtherLinksTableViewController.notificationsSwitchChanged), forControlEvents: UIControlEvents.ValueChanged)
            
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell!.selectionStyle = .Default
            cell!.accessoryType = .DisclosureIndicator
        }
        
        if (indexPath.section == 0) {
            switch (indexPath.row) {
            case 0:
                cell!.textLabel?.text = "Fixture List"
                let cellImage = UIImage(icon: FAType.FACalendar, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "Where's the Ground?"
                let cellImage = UIImage(icon: FAType.FAMapMarker, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
            case 2:
                cell!.textLabel?.text = "League Table"
                let cellImage = UIImage(icon: FAType.FATable, size: CGSize(width: 100, height: 100), textColor: AppColors.Fixtures, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        }
        else if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                cell!.textLabel?.text = "HTFC on Facebook"
                let cellImage = UIImage(icon: FAType.FAFacebookSquare, size: CGSize(width: 100, height: 100), textColor: AppColors.Facebook, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "NPL site"
                let cellImage = UIImage(icon: FAType.FASoccerBallO, size: CGSize(width: 100, height: 100), textColor: AppColors.Evostick, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            case 2:
                cell!.textLabel?.text = "Fantasy Island"
                let cellImage = UIImage(icon: FAType.FAPlane, size: CGSize(width: 100, height: 100), textColor: AppColors.Fantasy, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            case 3:
                cell!.textLabel?.text = "Stourbridge Town FC"
                let cellImage = UIImage(icon: FAType.FAThumbsODown, size: CGSize(width: 100, height: 100), textColor: AppColors.Stour, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if (indexPath.section == 2) {
            switch (indexPath.row) {
            case 0:
                cell!.textLabel?.text = "Yeltz Archives"
                let cellImage = UIImage(icon: FAType.FAArchive, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            case 1:
                cell!.textLabel?.text = "Yeltzland News Archive"
                let cellImage = UIImage(icon: FAType.FANewspaperO, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clearColor())
                cell!.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if (indexPath.section == 3) {
            cell!.textLabel?.text = "Game time tweets"
            let cellImage = UIImage(icon: FAType.FATwitter, size: CGSize(width: 100, height: 100), textColor: AppColors.TwitterIcon, backgroundColor: UIColor.clearColor())

            cell!.imageView?.image = cellImage

            cell!.detailTextLabel?.text = "Enable notifications"
        } else if (indexPath.section == 4) {
            cell!.textLabel?.text = "More Brave Location Apps"
            let cellImage = UIImage(icon: FAType.FAMapMarker, size: CGSize(width: 100, height: 100), textColor: AppColors.BraveLocation, backgroundColor: UIColor.clearColor())
            cell!.imageView?.image = cellImage
            
            let infoDictionary = NSBundle.mainBundle().infoDictionary!
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                let fixtures = FixturesTableViewController(style: .Grouped)
                self.navigationController!.pushViewController(fixtures, animated: true)
                return;
            } else if (indexPath.row == 1) {
                let locations = LocationsViewController()
                self.navigationController!.pushViewController(locations, animated: true)
                return;
            }
        }
        
        var url: NSURL? = nil;
        
        if (indexPath.section == 0) {
            if (indexPath.row == 2) {
                url = NSURL(string: "http://www.evostikleague.co.uk/match-info/tables")
            }
        } else if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                url = NSURL(string: "https://www.facebook.com/halesowentownfc/")
                break
            case 1:
                url = NSURL(string: "http://www.evostikleague.co.uk")
                break
            case 2:
                url = NSURL(string: "http://yeltz.co.uk/fantasyisland")
                break
            default:
                break
            }
        } else if (indexPath.section == 2) {
            switch (indexPath.row) {
            case 0:
                url = NSURL(string: "http://www.yeltzarchives.com")
                break
            case 1:
                url = NSURL(string: "http://www.yeltzland.net/news.html")
                break
            default:
                break
            }
        } else if (indexPath.section == 4) {
            url = NSURL(string: "https://bravelocation.com/apps")
        }
        
        if (url != nil) {
            let svc = SFSafariViewController(URL: url!)
            svc.delegate = self
            self.presentViewController(svc, animated: true, completion: nil)
        } else if (indexPath.section == 1 && indexPath.row == 3) {
            let alert = UIAlertController(title: "Really?", message: "Computer says no", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String
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
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.OtherSectionBackground
        header.textLabel!.textColor = AppColors.OtherSectionText
        header.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherSectionTextSize)!
    }
    
    // MARK: - Event handler for switch
    func notificationsSwitchChanged(sender: AnyObject) {
        let switchControl = sender as! UISwitch
        self.azureNotifications.enabled = switchControl.on
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func safariViewController(controller: SFSafariViewController,
                                activityItemsForURL URL: NSURL,
                                                    title: String?) -> [UIActivity] {
        let chromeActivity = ChromeActivity(currentUrl: URL)
        
        if (chromeActivity.canOpenChrome()) {
            return [chromeActivity];
        }
        
        return [];
    }
}
