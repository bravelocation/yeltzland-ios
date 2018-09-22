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
            template.textProvider = CLKSimpleTextProvider(text: settings.smallScore)
            template.tintColor = AppColors.WatchComplicationColor
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
        case .graphicBezel:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicBezelCircularText()
                template.textProvider = CLKSimpleTextProvider(text: settings.longCombinedTeamScoreOrDate)
                
                let imageProvider = CLKComplicationTemplateGraphicCircularImage()
                imageProvider.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Bezel")!)
                template.circularTemplate = imageProvider
                template.tintColor = AppColors.WatchComplicationColor
                
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            }
            break
        case .graphicCorner:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicCornerStackText()
                template.outerTextProvider = CLKSimpleTextProvider(text: settings.smallOpponent)
                template.innerTextProvider = CLKSimpleTextProvider(text: settings.smallScoreOrDate)
                template.tintColor = AppColors.WatchComplicationColor
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            }
            break
        case .graphicCircular:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
                template.bottomTextProvider = CLKSimpleTextProvider(text: settings.smallScoreOrDate)
                
                // Set H or A in center
                var homeOrAway = ""
                if let nextGameAtHome = settings.nextGameHome {
                    homeOrAway = nextGameAtHome ? "H" : "A"
                }

                template.centerTextProvider = CLKSimpleTextProvider(text: homeOrAway)
                
                let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: AppColors.WatchRingColor, fillFraction: 1.0)
                template.gaugeProvider = gauge
                
                template.tintColor = AppColors.WatchComplicationColor
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            }
            break
        case .graphicRectangular:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicRectangularStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: settings.fullTitle)
                template.body1TextProvider = CLKSimpleTextProvider(text: settings.fullTeam)
                template.body2TextProvider = CLKSimpleTextProvider(text: settings.fullScoreOrDate)
                template.tintColor = AppColors.WatchComplicationColor

                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            }
            break
        default:
            break
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
    
    // MARK: - Placeholder Templates
    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
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
            template.textProvider = CLKSimpleTextProvider(text: "2-0")
            template.tintColor = AppColors.WatchComplicationColor
            handler(template)
        case .graphicBezel:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicBezelCircularText()
                template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 10-0")
                
                let imageProvider = CLKComplicationTemplateGraphicCircularImage()
                imageProvider.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Bezel")!)
                template.circularTemplate = imageProvider
                template.tintColor = AppColors.WatchComplicationColor
                
                handler(template)
            }
            break
        case .graphicCorner:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicCornerStackText()
                template.outerTextProvider = CLKSimpleTextProvider(text: "STOU")
                template.innerTextProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            }
            break
        case .graphicCircular:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()
                template.bottomTextProvider = CLKSimpleTextProvider(text: "2-0")
                template.centerTextProvider = CLKSimpleTextProvider(text: "H")
                let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: AppColors.WatchRingColor, fillFraction: 1.0)
                template.gaugeProvider = gauge
                template.tintColor = AppColors.WatchComplicationColor

                handler(template)
            }
            break
        case .graphicRectangular:
            if #available(watchOS 5,*) {
                let template = CLKComplicationTemplateGraphicRectangularStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Next game:")
                template.body1TextProvider = CLKSimpleTextProvider(text: "Stourbridge")
                template.body2TextProvider = CLKSimpleTextProvider(text: "Tue 26 Dec")
                template.tintColor = AppColors.WatchComplicationColor
                
                handler(template)
            }
            break
        default:
            handler(nil)
            break
        }
    }
}
