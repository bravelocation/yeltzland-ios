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
        stats.elements.append(NavigationElement(title: "Fixture List",
                                                subtitle: nil,
                                                imageName: "fixtures",
                                                type: .controller(FixturesTableViewController(style: .grouped))))
        
        stats.elements.append(NavigationElement(title: "Latest Score",
                                                subtitle: nil,
                                                imageName: "latest-score",
                                                type: .controller(LatestScoreViewController())))
        
        stats.elements.append(NavigationElement(title: "Where's the Ground",
                                                subtitle: nil,
                                                imageName: "map",
                                                type: .controller(LocationsViewController())))
        
        stats.elements.append(NavigationElement(title: "League Table",
                                                subtitle: nil,
                                                imageName: "table",
                                                type: .link(URL(string: "https://southern-football-league.co.uk/league-table/Southern%20League%20Div%20One%20Central/2020/2021/P/")!)))
        sections.append(stats)
        
        // Other websites section
        var websites = NavigationSection(title: "Other websites", elements: [])
        websites.elements.append(NavigationElement(title: "HTFC on Facebook",
                                                   subtitle: nil,
                                                   imageName: "facebook",
                                                   type: .link(URL(string: "https://www.facebook.com/HalesowenTown1873")!)))
        
        websites.elements.append(NavigationElement(title: "Southern League site",
                                                   subtitle: nil,
                                                   imageName: "southern-league",
                                                   type: .link(URL(string: "https://southern-football-league.co.uk")!)))
        
        websites.elements.append(NavigationElement(title: "Fantasy Island",
                                                   subtitle: nil,
                                                   imageName: "fantasy-island",
                                                   type: .link(URL(string: "https://fantasyisland.yeltz.co.uk")!)))
        
        websites.elements.append(NavigationElement(title: "Stourbridge Town FC",
                                                   subtitle: nil,
                                                   imageName: "stourbridge",
                                                   type: .link(URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)))
        
        websites.elements.append(NavigationElement(title: "Yeltz Club Shop",
                                                   subtitle: nil,
                                                   imageName: "club-shop",
                                                   type: .link(URL(string: "https://www.yeltzclubshop.com")!)))
        sections.append(websites)
        
        // History section
        var history = NavigationSection(title: "Other websites", elements: [])
        history.elements.append(NavigationElement(title: "Follow Your Instinct",
                                                   subtitle: nil,
                                                   imageName: "fyi",
                                                   type: .link(URL(string: "https://www.yeltzland.net/followyourinstinct/")!)))
        
        history.elements.append(NavigationElement(title: "Yeltz Archives",
                                                   subtitle: nil,
                                                   imageName: "yeltz-archive",
                                                   type: .link(URL(string: "http://www.yeltzarchives.com")!)))
        
        history.elements.append(NavigationElement(title: "News Archive (1997-2006)",
                                                   subtitle: nil,
                                                   imageName: "news-archive",
                                                   type: .link(URL(string: "https://www.yeltzland.net/news.html")!)))
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
        moreLinks.elements.append(NavigationElement(title: "Yeltzland on Amazon Echo",
                                                   subtitle: nil,
                                                   imageName: "amazon",
                                                   type: .link(URL(string: "https://www.amazon.co.uk/Yeltzland-stuff-about-Halesowen-Town/dp/B01MTJOHBY/")!)))
        
        moreLinks.elements.append(NavigationElement(title: "Yeltzland on Google Assistant",
                                                   subtitle: nil,
                                                   imageName: "google",
                                                   type: .link(URL(string: "https://assistant.google.com/services/a/uid/000000a862d84885?hl=en-GB")!)))
        
        moreLinks.elements.append(NavigationElement(title: "Add Fixture List to Calendar",
                                                   subtitle: nil,
                                                   imageName: "fixtures",
                                                   type: .link(URL(string: "https://yeltzland.net/calendar-instructions")!)))
        
        sections.append(moreLinks)
        
        // Add to Siri section
        var siri = NavigationSection(title: "Add to Siri", elements: [])
        
        siri.elements.append(NavigationElement(title: "What's the latest score?",
                                               subtitle: nil,
                                               imageName: "siri",
                                               type: .siri(ShortcutManager.shared.latestScoreIntent())))
        
        siri.elements.append(NavigationElement(title: "Who do we play next?",
                                               subtitle: nil,
                                               imageName: "siri",
                                               type: .siri(ShortcutManager.shared.nextGameIntent())))
        sections.append(siri)

        // About section
        var about = NavigationSection(title: "About", elements: [])
        
        about.elements.append(NavigationElement(title: "Privacy Policy",
                                               subtitle: nil,
                                               imageName: nil,
                                               type: .link(URL(string: "https://bravelocation.com/privacy/yeltzland")!)))
        
        about.elements.append(NavigationElement(title: "Icons from icons8.com",
                                               subtitle: nil,
                                               imageName: nil,
                                               type: .link(URL(string: "https://icons8.com")!)))
        
        about.elements.append(NavigationElement(title: "More Brave Location Apps",
                                               subtitle: nil,
                                               imageName: nil,
                                               type: .link(URL(string: "https://bravelocation.com/apps")!)))
        
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"]
        let build = infoDictionary["CFBundleVersion"]
        about.elements.append(NavigationElement(title: "",
                                               subtitle: "v\(version!).\(build!)",
                                               imageName: nil,
                                               type: .info))
        sections.append(about)
    }
}
