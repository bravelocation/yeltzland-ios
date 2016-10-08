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
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        
        let settings = WatchGameSettings.instance
        let now = Date()
        var entry : CLKComplicationTimelineEntry?
        
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: settings.smallOpponent)
            template.line2TextProvider = CLKSimpleTextProvider(text: settings.smallScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: settings.fullTitle)
            template.body1TextProvider = CLKSimpleTextProvider(text: settings.fullTeam)
            template.body2TextProvider = CLKSimpleTextProvider(text: settings.fullScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: settings.smallScore)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: settings.longCombinedTeamScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: settings.smallOpponent)
            template.line2TextProvider = CLKSimpleTextProvider(text: settings.smallScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: settings.longCombinedTeamScoreOrDate)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        }
        
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
        // Not supporting timeline
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
        // Not supporting timeline
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        
        // Update every 6 hours by default - the app will push in updates if they occur
        var minutesToNextUpdate = 360.0
        
        let gameState = WatchGameSettings.instance.currentGameState()
        if (gameState == BaseSettings.GameState.during || gameState == BaseSettings.GameState.duringNoScore) {
            // During match, update every 15 minutes
            minutesToNextUpdate = 15.0
        } else if (gameState == BaseSettings.GameState.gameDayBefore || gameState == BaseSettings.GameState.after) {
            // On rest of game day (or day after), update every hour
            minutesToNextUpdate = 60.0
        }
        
        let requestTime = Date().addingTimeInterval(minutesToNextUpdate * 60.0)
        handler(requestTime)
        
        print("Requested for complications to be updated in %3.0f minutes", minutesToNextUpdate)
    }
    
    // MARK: - Placeholder Templates
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "STOU")
                template.line2TextProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Next game:")
                template.body1TextProvider = CLKSimpleTextProvider(text: "Stourbridge")
                template.body2TextProvider = CLKSimpleTextProvider(text: "Tue 26 Dec")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .utilitarianSmall, .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 10-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "STOU")
                template.line2TextProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 10-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
        }
    }
}
