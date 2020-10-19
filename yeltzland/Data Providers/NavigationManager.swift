//
//  NavigationManager.swift
//  Yeltzland
//
//  Created by John Pollard on 17/10/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public class NavigationManager {
    private var sections: [NavigationSection] = []
    
    var moreSections: [NavigationSection] {
        get {
            self.sections
        }
    }
    
    init() {
        // Add Statistics Section
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
        sections.append(stats)
        
        // Other websites section
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
        sections.append(websites)
        
        // History section
        var history = NavigationSection(title: "Other websites", elements: [])
        history.elements.append(NavigationElement.link(title: "Follow Your Instinct",
                                                   imageName: "fyi",
                                                   url: "https://www.yeltzland.net/followyourinstinct/"))
        
        history.elements.append(NavigationElement.link(title: "Yeltz Archives",
                                                   imageName: "yeltz-archive",
                                                   url: "http://www.yeltzarchives.com"))
        
        history.elements.append(NavigationElement.link(title: "News Archive (1997-2006)",
                                                   imageName: "news-archive",
                                                   url: "https://www.yeltzland.net/news.html"))
        sections.append(history)
        
        // Options section
        var options = NavigationSection(title: "Options", elements: [])
        options.elements.append(NavigationElement(title: "Game time tweets",
                                                  subtitle: "Enable notifications",
                                                  imageName: "game-time",
                                                  type: .notificationsSettings))
        
        sections.append(options)
        
        // More links section
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
        
        sections.append(moreLinks)
        
        // Add to Siri section
        var siri = NavigationSection(title: "Add to Siri", elements: [])
        
        siri.elements.append(NavigationElement.siri(title: "What's the latest score?",
                                               intent: ShortcutManager.shared.latestScoreIntent()))
        
        siri.elements.append(NavigationElement.siri(title: "Who do we play next?",
                                                    intent: ShortcutManager.shared.nextGameIntent()))
        sections.append(siri)

        // About section
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
        
        sections.append(about)
    }
}
