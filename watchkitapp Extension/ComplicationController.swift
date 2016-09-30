//
//  ComplicationController.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        
        let settings = WatchGameSettings.instance
        let now = NSDate()
        var entry : CLKComplicationTimelineEntry?
        
        switch complication.family {
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: settings.smallOpponent)
            template.line2TextProvider = CLKSimpleTextProvider(text: settings.smallScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: settings.fullTitle)
            template.body1TextProvider = CLKSimpleTextProvider(text: settings.fullTeam)
            template.body2TextProvider = CLKSimpleTextProvider(text: settings.fullScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .UtilitarianSmall, .UtilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: settings.smallScore)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .UtilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: settings.longCombinedTeamScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: settings.smallOpponent)
            template.line2TextProvider = CLKSimpleTextProvider(text: settings.smallScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .ExtraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: settings.longCombinedTeamScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        }
        
        handler(entry)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Not supporting timeline
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Not supporting timeline
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        
        // Update every 6 hours by default - the app will push in updates if they occur
        var minutesToNextUpdate = 360.0
        
        let gameState = WatchGameSettings.instance.currentGameState()
        if (gameState == BaseSettings.GameState.During || gameState == BaseSettings.GameState.DuringNoScore) {
            // During match, update every 15 minutes
            minutesToNextUpdate = 15.0
        } else if (gameState == BaseSettings.GameState.GameDayBefore || gameState == BaseSettings.GameState.After) {
            // On rest of game day (or day after), update every hour
            minutesToNextUpdate = 60.0
        }
        
        let requestTime = NSDate().dateByAddingTimeInterval(minutesToNextUpdate * 60.0)
        handler(requestTime)
        
        print("Requested for complications to be updated in %3.0f minutes", minutesToNextUpdate)
    }
    
    // MARK: - Placeholder Templates
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
            case .ModularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "STOU")
                template.line2TextProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .ModularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Next game:")
                template.body1TextProvider = CLKSimpleTextProvider(text: "Stourbridge")
                template.body2TextProvider = CLKSimpleTextProvider(text: "Tue 26 Dec")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .UtilitarianSmall, .UtilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .UtilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 10-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .CircularSmall:
                let template = CLKComplicationTemplateCircularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "STOU")
                template.line2TextProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .ExtraLarge:
                let template = CLKComplicationTemplateExtraLargeSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 10-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
        }
    }
}
