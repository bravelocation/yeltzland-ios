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
    //swiftlint:disable:next cyclomatic_complexity
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        
        let now = Date()
        var entry: CLKComplicationTimelineEntry?
        
        let timelineManager = TimelineManager(
            fixtureManager: FixtureManager.shared,
            gameScoreManager: GameScoreManager.shared
        )
        
        // Find the next fixture to use
        if let fixture = timelineManager.timelineEntries.first {
            var abbreviatedScoreOrDate = ""
            var fullScoreOrDate = ""
            var gameType = ""
            
            switch fixture.status {
            case .inProgress:
                abbreviatedScoreOrDate = fixture.score
                fullScoreOrDate = fixture.score
                gameType = "In progress"
            case .result:
                abbreviatedScoreOrDate = fixture.score
                fullScoreOrDate = fixture.score
                gameType = "Result"
            case .fixture:
                abbreviatedScoreOrDate = fixture.minimalKickoffTime
                fullScoreOrDate = fixture.kickoffTime
                gameType = "Next game"
            }
            
            switch complication.family {
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: fixture.opponentAbbreviation)
                template.line2TextProvider = CLKSimpleTextProvider(text: abbreviatedScoreOrDate)
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: gameType)
                template.body1TextProvider = CLKSimpleTextProvider(text: fixture.opponentShortened)
                template.body2TextProvider = CLKSimpleTextProvider(text: fullScoreOrDate)
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .utilitarianSmall, .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: String(format: "%@ %@", fixture.opponentAbbreviation, abbreviatedScoreOrDate))
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: String(format: "%@ %@", fixture.opponentShortened, abbreviatedScoreOrDate))
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: fixture.opponentAbbreviation)
                template.line2TextProvider = CLKSimpleTextProvider(text: abbreviatedScoreOrDate)
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: fixture.opponentAbbreviation)
                template.line2TextProvider = CLKSimpleTextProvider(text: abbreviatedScoreOrDate)
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .graphicBezel:
                let template = CLKComplicationTemplateGraphicBezelCircularText()
                template.textProvider = CLKSimpleTextProvider(text: String(format: "%@ %@", fixture.opponentShortened, abbreviatedScoreOrDate))
                
                let imageProvider = CLKComplicationTemplateGraphicCircularImage()
                imageProvider.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Bezel")!)
                template.circularTemplate = imageProvider
                template.tintColor = UIColor(named: "light-blue")
                
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .graphicCorner:
                let template = CLKComplicationTemplateGraphicCornerStackText()
                template.outerTextProvider = CLKSimpleTextProvider(text: fixture.opponentAbbreviation)
                template.innerTextProvider = CLKSimpleTextProvider(text: abbreviatedScoreOrDate)
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .graphicCircular:
                let template = CLKComplicationTemplateGraphicCircularImage()
                template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
                template.tintColor = UIColor(named: "light-blue")
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            case .graphicRectangular:
                let template = CLKComplicationTemplateGraphicRectangularStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: gameType)
                template.body1TextProvider = CLKSimpleTextProvider(text: fixture.opponentShortened)
                template.body2TextProvider = CLKSimpleTextProvider(text: fullScoreOrDate)
                template.tintColor = UIColor(named: "light-blue")
                
                entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: template)
            default:
                break
            }
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
    //swiftlint:disable:next cyclomatic_complexity
    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "STOU")
            template.line2TextProvider = CLKSimpleTextProvider(text: "2-0")
            template.tintColor = UIColor(named: "light-blue")
            handler(template)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Next game:")
            template.body1TextProvider = CLKSimpleTextProvider(text: "Stourbridge")
            template.body2TextProvider = CLKSimpleTextProvider(text: "Tue 26 Dec")
            template.tintColor = UIColor(named: "light-blue")
            handler(template)
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "2-0")
            template.tintColor = UIColor(named: "light-blue")
            handler(template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 10-0")
            template.tintColor = UIColor(named: "light-blue")
            handler(template)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "STOU")
            template.line2TextProvider = CLKSimpleTextProvider(text: "2-0")
            template.tintColor = UIColor(named: "light-blue")
            handler(template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "2-0")
            template.tintColor = UIColor(named: "light-blue")
            handler(template)
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 10-0")
            
            let imageProvider = CLKComplicationTemplateGraphicCircularImage()
            imageProvider.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Bezel")!)
            template.circularTemplate = imageProvider
            template.tintColor = UIColor(named: "light-blue")
            
            handler(template)
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.outerTextProvider = CLKSimpleTextProvider(text: "STOU")
            template.innerTextProvider = CLKSimpleTextProvider(text: "2-0")
            template.tintColor = UIColor(named: "light-blue")
            handler(template)
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
            template.tintColor = UIColor(named: "light-blue")

            handler(template)
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Next game:")
            template.body1TextProvider = CLKSimpleTextProvider(text: "Stourbridge")
            template.body2TextProvider = CLKSimpleTextProvider(text: "Tue 26 Dec")
            template.tintColor = UIColor(named: "light-blue")
            
            handler(template)
        default:
            handler(nil)
        }
    }
}
