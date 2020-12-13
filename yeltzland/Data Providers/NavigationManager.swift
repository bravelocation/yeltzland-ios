//
//  NavigationManager.swift
//  Yeltzland
//
//  Created by John Pollard on 17/10/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

public class NavigationManager {
    // MARK: - Private variables
    
    private var _main: NavigationSection = NavigationSection(title: "Yeltzland", elements: [])
    private var _moreSections: [NavigationSection] = []
    private var _lastUserActivity: NSUserActivity?
    
    private let fixtureList: NavigationElement = NavigationElement.controller(title: "Fixture List",
                                                                               imageName: "fixtures",
                                                                               controller: FixturesTableViewController(style: .grouped),
                                                                               keyboardShortcut: "F",
                                                                               activityInfo: ActivityInfo(
                                                                                   title: "Yeltz Fixture List",
                                                                                   invocationPhrase: "Fixture List"))
    
    private let latestScore: NavigationElement = NavigationElement.controller(title: "Latest Score",
                                                                               imageName: "latest-score",
                                                                               controller: LatestScoreViewController(),
                                                                               keyboardShortcut: "L",
                                                                               activityInfo: ActivityInfo(
                                                                                   title: "Latest Yeltz Score",
                                                                                   invocationPhrase: "Latest Yeltz Score"))
    
    // MARK: - Public properties
    
    public var mainSection: NavigationSection {
        get {
            self._main
        }
    }
    
    public var moreSections: [NavigationSection] {
        get {
            self._moreSections
        }
    }
    
    public var lastUserActivity: NSUserActivity? {
        get {
            return self._lastUserActivity
        }
        set {
            self._lastUserActivity = newValue
        }
    }
    
    // MARK: - Initialisation
    
    public init() {
        self.addMainNavigation()
        self.addStatisticsSection()
        self.addOtherWebsitesSection()
        self.addHistorySection()
        self.addOptionsSection()
        self.addMoreLinksSection()
        self.addSiriSection()
        self.addAboutSection()
    }
    
    // MARK: - Public functions
    
    public func keyCommands(selector: Selector, useMore: Bool) -> [UIKeyCommand] {
        var commands: [UIKeyCommand] = []
        
        var i = 1
        for mainNavElement in self._main.elements {
            if #available(iOS 13.0, *) {
                commands.append(UIKeyCommand(title: mainNavElement.title, action: selector, input: "\(i)", modifierFlags: .command))
            } else {
                commands.append(UIKeyCommand(input: "\(i)", modifierFlags: .command, action: selector, discoverabilityTitle: mainNavElement.title))
            }
            
            i += 1
        }
        
        if useMore {
            if #available(iOS 13.0, *) {
                commands.append(UIKeyCommand(title: "More", action: selector, input: "\(i)", modifierFlags: .command))
            } else {
                commands.append(UIKeyCommand(input: "\(i)", modifierFlags: .command, action: selector, discoverabilityTitle: "More"))
            }
        }
        
        // Find any additional elements
        for moreNavElement in self._moreSections {
            for moreElement in moreNavElement.elements {
                if let keyboardShort = moreElement.keyboardShortcut {
                    if #available(iOS 13.0, *) {
                        commands.append(UIKeyCommand(title: moreElement.title, action: selector, input: keyboardShort, modifierFlags: .command))
                    } else {
                        commands.append(UIKeyCommand(input: keyboardShort, modifierFlags: .command, action: selector, discoverabilityTitle: moreElement.title))
                    }
                }
            }
        }
        
        return commands
    }
    
    public func userActivity(for indexPath: IndexPath,
                             delegate: NSUserActivityDelegate?,
                             adjustForHeaders: Bool,
                             moreOnly: Bool,
                             url: URL?) -> NSUserActivity? {
        let elementIndex = adjustForHeaders ? indexPath.row - 1: indexPath.row // Adjust for header in sidebar
        
        if (indexPath.section == 0 && moreOnly == false) {
            guard elementIndex >= 0 && elementIndex < self.mainSection.elements.count else {
                return nil
            }
            
            // Set activity for handoff
            return self.buildUserActivity(
                delegate: delegate,
                navigationElement: self.mainSection.elements[elementIndex],
                url: url)
        }
        
        let sectionIndex = moreOnly ? indexPath.section : indexPath.section - 1
        
        guard sectionIndex >= 0 && sectionIndex < self.moreSections.count else {
            return nil
        }
        
        let section = self.moreSections[sectionIndex]
        
        guard elementIndex >= 0 && elementIndex < section.elements.count else {
            return nil
        }
        
        // Set activity for handoff
        return self.buildUserActivity(
            delegate: delegate,
            navigationElement: section.elements[elementIndex])
    }
    
    public func findIndexPathForSidebarNavigationActivity(_ navActivity: NavigationActivity) -> IndexPath? {
        if navActivity.main {
            var row = 1 // Headers!
            
            for mainElement in self.mainSection.elements {
                if mainElement.id == navActivity.navElementId {
                    return IndexPath(row: row, section: 0)
                }
                
                row += 1
            }
        } else {
            var section = 1
            
            for moreSection in self.moreSections {
                var row = 1 // Headers!
                for moreElement in moreSection.elements {
                    if moreElement.id == navActivity.navElementId {
                        return IndexPath(row: row, section: section)
                    }
                    
                    row += 1
                }
                
                section += 1
            }
        }
    
        return nil
    }
    
    public func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> NavigationActivity {
        print("Handling shortcut item %@", shortcutItem.type)
        
        for navigationElement in self.mainSection.elements {
            if let shortcutName = navigationElement.shortcutName {
                if shortcutItem.type == shortcutName {
                    return NavigationActivity(main: true, navElementId: navigationElement.id)
                }
            }
        }
        
        // If no match found, go to the first element
        return NavigationActivity(main: true, navElementId: self.mainSection.elements[0].id)
    }
    
    public func convertLegacyActivity(_ activity: NSUserActivity) -> NSUserActivity? {
        if (activity.activityType == "com.bravelocation.yeltzland.navigation") {
            return activity
        }
        
        if (activity.activityType == "com.bravelocation.yeltzland.currenttab") {
            if let info = activity.userInfo {
                if let tab = info["com.bravelocation.yeltzland.currenttab.key"] {
                    let tabIndex = tab as! Int
                    
                    if tabIndex >= 0 && tabIndex < self.mainSection.elements.count {
                        var url: URL?
                        
                        if let currentUrl = info["com.bravelocation.yeltzland.currenttab.currenturl"] as? NSURL {
                            url = currentUrl.absoluteURL
                        }
                        
                        return self.buildUserActivity(delegate: activity.delegate, navigationElement: self.mainSection.elements[tabIndex], url: url)
                    }
                }
            }
        }
        
        if (activity.activityType == "com.bravelocation.yeltzland.fixtures") {
            return self.buildUserActivity(delegate: activity.delegate, navigationElement: self.fixtureList)
        }
        
        if (activity.activityType == "com.bravelocation.yeltzland.latestscore") {
            print("Detected Latest score activity ...")
            
            return self.buildUserActivity(delegate: activity.delegate, navigationElement: self.latestScore)
        }
        
        return nil
    }
    
    // MARK: - Private helper methods
    
    private func buildUserActivity(delegate: NSUserActivityDelegate?, navigationElement: NavigationElement, url: URL? = nil) -> NSUserActivity {
        // Set activity for handoff
        let activity = NSUserActivity(activityType: "com.bravelocation.yeltzland.navigation")
        activity.delegate = delegate
        
        // Eligible for handoff
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true

        // Set the title
        var activityTitle = "Open \(navigationElement.title)"
        var activityInvocationPhrase = "Open \(navigationElement.title)"
        
        if let activityInfo = navigationElement.activityInfo {
            activityTitle = activityInfo.title
            activityInvocationPhrase = activityInfo.invocationPhrase
        }
    
        activity.title = activityTitle
        activity.suggestedInvocationPhrase = activityInvocationPhrase
        
        let navigationActivity = NavigationActivity(main: self.isMainElement(navigationElement),
                                                    navElementId: navigationElement.id,
                                                    url: url)
        
        activity.userInfo = navigationActivity.userInfo
        
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = String(format: "%@.com.bravelocation.yeltzland.navigation.%@", Bundle.main.bundleIdentifier!, navigationElement.id)
        activity.needsSave = true
        
        return activity
    }
    
    private func isMainElement(_ navElement: NavigationElement) -> Bool {
        for element in self._main.elements where element.id == navElement.id {
            return true
        }
        
        return false
    }
    
    private func findMoreElement(_ element: NavigationElement) -> IndexPath? {
        var section = 0
        
        for moreSection in self._moreSections {
            var row = 0
            
            for moreElement in moreSection.elements {
                if moreElement.id == element.id {
                    return IndexPath(row: row, section: section)
                }
                
                row += 1
            }
            
            section += 1
        }
        
        return nil
    }
    
    // MARK: - Navigation setup
    private func addMainNavigation() {
        self._main.elements.append(NavigationElement.link(title: "Yeltz Forum",
                                                                imageName: "forum",
                                                                url: "https://www.yeltz.co.uk",
                                                                shortcutName: "com.bravelocation.yeltzland.forum",
                                                                activityInfo: ActivityInfo(
                                                                    title: "Read Yeltz Forum",
                                                                    invocationPhrase: "Read the forum")))
        
        self._main.elements.append(NavigationElement.link(title: "Official Site",
                                                                imageName: "official",
                                                                url: "https://www.ht-fc.co.uk",
                                                                shortcutName: "com.bravelocation.yeltzland.official",
                                                                activityInfo: ActivityInfo(
                                                                    title: "Read HTFC Official Site",
                                                                    invocationPhrase: "Read the club website")))
        
        self._main.elements.append(NavigationElement.link(title: "Yeltz TV",
                                                                imageName: "yeltztv",
                                                                url: "https://www.youtube.com/channel/UCGZMWQtMsC4Tep6uLm5V0nQ",
                                                                shortcutName: "com.bravelocation.yeltzland.yeltztv",
                                                                activityInfo: ActivityInfo(
                                                                    title: "Watch Yeltz TV",
                                                                    invocationPhrase: "Watch Yeltz TV")))
        
        // Twitter
        let twitterAccountName = "halesowentownfc"
        
        if #available(iOS 13.0, *) {
            let twitterViewController = TwitterHostingController<AnyView>(twitterAccountName: twitterAccountName)
            
            self._main.elements.append(NavigationElement.controller(title: "@\(twitterAccountName)",
                                                                    imageName: "twitter",
                                                                    controller: twitterViewController,
                                                                    shortcutName: "com.bravelocation.yeltzland.twitter",
                                                                    activityInfo: ActivityInfo(
                                                                        title: "Read HTFC Twitter Feed",
                                                                        invocationPhrase: "Read the club twitter")))
        } else {
            self._main.elements.append(NavigationElement.link(title: "@\(twitterAccountName)",
                                                                    imageName: "twitter",
                                                                    url: "https://mobile.twitter.com/\(twitterAccountName)",
                                                                    shortcutName: "com.bravelocation.yeltzland.twitter",
                                                                    activityInfo: ActivityInfo(
                                                                        title: "Read HTFC Twitter Feed",
                                                                        invocationPhrase: "Read the club twitter")))
        }
    }
    
    private func addStatisticsSection() {
        var stats = NavigationSection(title: "Statistics", elements: [])
                                      
        stats.elements.append(self.fixtureList)
        stats.elements.append(self.latestScore)
        
        stats.elements.append(NavigationElement.controller(title: "Where's the Ground",
                                                imageName: "map",
                                                controller: LocationsViewController(),
                                                keyboardShortcut: "G"))
        
        stats.elements.append(NavigationElement.link(title: "League Table",
                                                imageName: "table",
                                                url: "https://southern-football-league.co.uk/league-table/Southern%20League%20Div%20One%20Central/2020/2021/P/",
                                                keyboardShortcut: "T"))
        _moreSections.append(stats)
    }
    
    private func addOtherWebsitesSection() {
        
        var websites = NavigationSection(title: "Other websites", elements: [])
        websites.elements.append(NavigationElement.link(title: "HTFC on Facebook",
                                                   imageName: "facebook",
                                                   url: "https://www.facebook.com/HalesowenTown1873"))
        
        websites.elements.append(NavigationElement.link(title: "Southern League site",
                                                   imageName: "southern-league",
                                                   url: "https://southern-football-league.co.uk"))
        
        websites.elements.append(NavigationElement.link(title: "Fantasy Island",
                                                   imageName: "fantasy-island",
                                                   url: "https://fantasyisland.yeltz.co.uk"))
        
        websites.elements.append(NavigationElement.link(title: "Stourbridge Town FC",
                                                   imageName: "stourbridge",
                                                   url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"))
        
        websites.elements.append(NavigationElement.link(title: "Yeltz Club Shop",
                                                   imageName: "club-shop",
                                                   url: "https://www.yeltzclubshop.com"))
        _moreSections.append(websites)
    }
    
    private func addHistorySection() {

        var history = NavigationSection(title: "Know your history", elements: [])
        history.elements.append(NavigationElement.link(title: "Follow Your Instinct",
                                                   imageName: "fyi",
                                                   url: "https://www.yeltzland.net/followyourinstinct/"))
        
        /*
        history.elements.append(NavigationElement.link(title: "Yeltz Archives",
                                                   imageName: "yeltz-archive",
                                                   url: "http://www.yeltzarchives.com"))
         */
        
        history.elements.append(NavigationElement.link(title: "News Archive (1997-2006)",
                                                   imageName: "news-archive",
                                                   url: "https://www.yeltzland.net/news.html"))
        _moreSections.append(history)
    }
    
    private func addOptionsSection() {

        var options = NavigationSection(title: "Options", elements: [])
        options.elements.append(NavigationElement(title: "Game time tweets",
                                                  subtitle: "Notifications during the match",
                                                  imageName: "game-time",
                                                  type: .controller(GameTimeTweetsViewController())))
        
        _moreSections.append(options)
        
    }
    
    private func addMoreLinksSection() {

        var moreLinks = NavigationSection(title: "More from Yeltzland", elements: [])
        moreLinks.elements.append(NavigationElement.link(title: "Yeltzland on Amazon Echo",
                                                   imageName: "amazon",
                                                   url: "https://www.amazon.co.uk/Yeltzland-stuff-about-Halesowen-Town/dp/B01MTJOHBY/"))
        
        moreLinks.elements.append(NavigationElement.link(title: "Yeltzland on Google Assistant",
                                                   imageName: "google",
                                                   url: "https://assistant.google.com/services/a/uid/000000a862d84885?hl=en-GB"))
        
        moreLinks.elements.append(NavigationElement.link(title: "Add Fixture List to Calendar",
                                                   imageName: "fixtures",
                                                   url: "https://yeltzland.net/calendar-instructions"))
        
        _moreSections.append(moreLinks)
    }
    
    private func addSiriSection() {
        
        var siri = NavigationSection(title: "Add to Siri", elements: [])
        
        siri.elements.append(NavigationElement.siri(title: "What's the latest score?",
                                               intent: ShortcutManager.shared.latestScoreIntent()))
        
        siri.elements.append(NavigationElement.siri(title: "Who do we play next?",
                                                    intent: ShortcutManager.shared.nextGameIntent()))
        _moreSections.append(siri)
    }
    
    private func addAboutSection() {
        
        var about = NavigationSection(title: "About", elements: [])
        
        about.elements.append(NavigationElement.link(title: "Privacy Policy",
                                               imageName: nil,
                                               url: "https://bravelocation.com/privacy/yeltzland"))
        
        about.elements.append(NavigationElement.link(title: "Icons from icons8.com",
                                               imageName: nil,
                                               url: "https://icons8.com"))
        
        about.elements.append(NavigationElement.link(title: "About Brave Location",
                                               imageName: nil,
                                               url: "https://bravelocation.com/about"))
        
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"]
        let build = infoDictionary["CFBundleVersion"]
        about.elements.append(NavigationElement.info(info: "v\(version!).\(build!)"))
        
        _moreSections.append(about)
    }
}
