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
    private var _main: NavigationSection = NavigationSection(title: "Yeltzland", elements: [])
    private var _moreSections: [NavigationSection] = []
    
    var mainSection: NavigationSection {
        get {
            self._main
        }
    }
    
    var moreSections: [NavigationSection] {
        get {
            self._moreSections
        }
    }
    
    init() {
        if #available(iOS 14, *) {
            self.addMainNavigation()
        }
        
        self.addStatisticsSection()
        self.addOtherWebsitesSection()
        self.addHistorySection()
        self.addOptionsSection()
        self.addMoreLinksSection()
        self.addSiriSection()
        self.addAboutSection()
    }
    
    @available(iOS 14, *)
    private func addMainNavigation() {
        self._main.elements.append(NavigationElement.link(title: "Yeltz Forum",
                                                                imageName: "forum",
                                                                url: "https://www.yeltz.co.uk"))
        
        self._main.elements.append(NavigationElement.link(title: "Official Site",
                                                                imageName: "official",
                                                                url: "https://www.ht-fc.co.uk"))
        
        self._main.elements.append(NavigationElement.link(title: "Yeltz TV",
                                                                imageName: "yeltztv",
                                                                url: "https://www.youtube.com/channel/UCGZMWQtMsC4Tep6uLm5V0nQ"))
        
        // Twitter
        let twitterAccountName = "halesowentownfc"        
        let twitterConsumerKey = SettingsManager.shared.getSetting("TwitterConsumerKey") as! String
        let twitterConsumerSecret = SettingsManager.shared.getSetting("TwitterConsumerSecret") as! String
        
        let twitterDataProvider = TwitterDataProvider(
            twitterConsumerKey: twitterConsumerKey,
            twitterConsumerSecret: twitterConsumerSecret,
            tweetCount: 20,
            accountName: twitterAccountName
        )
        
        let tweetData = TweetData(dataProvider: twitterDataProvider, accountName: twitterAccountName)
        let twitterViewController = UIHostingController(rootView: TwitterView().environmentObject(tweetData))
        
        self._main.elements.append(NavigationElement.controller(title: "@\(twitterAccountName)",
                                                                imageName: "twitter",
                                                                controller: twitterViewController))
    }
    
    private func addStatisticsSection() {
        var stats = NavigationSection(title: "Statistics", elements: [])
                                      
        stats.elements.append(NavigationElement.controller(title: "Fixture List",
                                                imageName: "fixtures",
                                                controller: FixturesTableViewController(style: .grouped)))
        
        stats.elements.append(NavigationElement.controller(title: "Latest Score",
                                                imageName: "latest-score",
                                                controller: LatestScoreViewController()))
        
        stats.elements.append(NavigationElement.controller(title: "Where's the Ground",
                                                imageName: "map",
                                                controller: LocationsViewController()))
        
        stats.elements.append(NavigationElement.link(title: "League Table",
                                                imageName: "table",
                                                url: "https://southern-football-league.co.uk/league-table/Southern%20League%20Div%20One%20Central/2020/2021/P/"))
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
        
        about.elements.append(NavigationElement.link(title: "More Brave Location Apps",
                                               imageName: nil,
                                               url: "https://bravelocation.com/apps"))
        
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"]
        let build = infoDictionary["CFBundleVersion"]
        about.elements.append(NavigationElement.info(info: "v\(version!).\(build!)"))
        
        _moreSections.append(about)
    }
}
