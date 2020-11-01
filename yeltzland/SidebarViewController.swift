//
//  SidebarViewController.swift
//  Yeltzland
//
//  Created by John Pollard on 25/10/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit
import SafariServices
import Intents
import IntentsUI

@available(iOS 14, *)
class SidebarViewController: UIViewController {
    
    private enum SidebarItemType: Int {
        case header, row
    }
    
    private enum SidebarSection: Int {
        case main, more
    }
    
    private struct SidebarItem: Hashable, Identifiable {
        let id: UUID
        let type: SidebarItemType
        let element: NavigationElement
        
        static func header(title: String, id: UUID = UUID()) -> Self {
            let titleElement = NavigationElement(title: title, subtitle: nil, imageName: nil, type: .info)
            return SidebarItem(id: id, type: .header, element: titleElement)
        }
        
        static func row(element: NavigationElement, id: UUID = UUID()) -> Self {
            return SidebarItem(id: id,
                               type: .row,
                               element: element
            )
        }
        
        func elementImage(color: UIColor) -> UIImage? {
            var itemImage: UIImage?
            if let imageName = self.element.imageName {
                itemImage = UIImage(named: imageName)?.sd_tintedImage(with: color)
            }
            
            return itemImage
        }
        
        static func == (lhs: SidebarViewController.SidebarItem, rhs: SidebarViewController.SidebarItem) -> Bool {
            return lhs.id == rhs.id
        }
    
    }

    private struct RowIdentifier {
        static let allRecipes = UUID()
        static let favorites = UUID()
        static let recents = UUID()
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!
    private var navigationData: NavigationManager = NavigationManager()
    private var highlightColor: UIColor = UIColor(named: "blue-tint")!
    private var highlightTextColor: UIColor = UIColor(named: "row-highlight-text-color")!
    private var rowTextColor: UIColor = UIColor(named: "row-text-color")!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureCollectionView()
        self.configureDataSource()
        self.applyInitialSnapshot()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Reload the table on trait change, in particular to change images on dark mode change
        self.collectionView.reloadData()
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.tintColor = self.highlightColor
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = .firstItemInSection
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
        
        return layout
    }
}

@available(iOS 14, *)
extension SidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch indexPath.section {
        case SidebarSection.main.rawValue, SidebarSection.more.rawValue:
            didSelectItem(sidebarItem, at: indexPath)
        default:
            didDeselectItem(sidebarItem, at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        if sidebarItem.type == .header {
            return false
        }
        
        if sidebarItem.element.type == .info {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        didDeselectItem(sidebarItem, at: indexPath)
    }
    
    private func updateDetailViewController(controller: UIViewController) {
        if let splitViewController = self.splitViewController {
            splitViewController.showDetailViewController(controller, sender: nil)
        }
    }
    
    private func didSelectItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
        // Change the color of the image and text
        if let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell {
            if let config = cell.contentConfiguration as? UIListContentConfiguration {
                cell.contentConfiguration = self.setConfigurationColors(config, item: sidebarItem, selected: true)
            }
        }
        
        switch sidebarItem.element.type {
        case .controller(let viewController):
            let navViewController = UINavigationController(rootViewController: viewController)
            self.updateDetailViewController(controller: navViewController)
            return 
        case .siri(let intent):
            self.addToSiriAction(intent: intent)
            return
        case .link(let url):
            let webViewController = WebPageViewController()
            webViewController.homeUrl = url
            webViewController.pageTitle = sidebarItem.element.title
            let navViewController = UINavigationController(rootViewController: webViewController)
            
            self.updateDetailViewController(controller: navViewController)
            return
        default:
            return
            // NO action on other types
        }
    }
    
    private func didDeselectItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
        // Change the color of the image and text
        if let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell {
            if let config = cell.contentConfiguration as? UIListContentConfiguration {
                cell.contentConfiguration = self.setConfigurationColors(config, item: sidebarItem, selected: false)
            }
        }
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, _, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.element.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            contentConfiguration.textProperties.color = self.highlightColor
            
            cell.contentConfiguration = contentConfiguration
        }
        
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, _, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
            contentConfiguration.text = item.element.title
            contentConfiguration.secondaryText = item.element.subtitle
            
            cell.contentConfiguration = self.setConfigurationColors(contentConfiguration, item: item, selected: cell.isSelected)
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell in
            
            switch item.type {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            default:
                return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
            }
        }
    }
    
    private func setConfigurationColors(_ config: UIListContentConfiguration, item: SidebarItem, selected: Bool) -> UIListContentConfiguration {
        var contentConfiguration = config
        contentConfiguration.image = item.elementImage(color: selected ? self.highlightTextColor : self.highlightColor)
        contentConfiguration.textProperties.color = selected ? self.highlightTextColor : self.rowTextColor
        contentConfiguration.secondaryTextProperties.color = selected ? self.highlightTextColor : self.rowTextColor
        
        return contentConfiguration
    }
    
    private func mainElementsSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        
        let sectionHeader = SidebarItem.header(title: "Yeltzland")
        
        var mainNavItems: [SidebarItem] = []
        for mainNavElement in self.navigationData.mainSection.elements {
            mainNavItems.append(SidebarItem.row(element: mainNavElement))
        }
            
        snapshot.append([sectionHeader])
        snapshot.expand([sectionHeader])
        snapshot.append(mainNavItems, to: sectionHeader)
        
        return snapshot
    }
    
    private func moreElementsSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        
        for moreSection in self.navigationData.moreSections {
            let sectionHeader = SidebarItem.header(title: moreSection.title)
            
            var moreSectionNavItems: [SidebarItem] = []
            for moreNavElement in moreSection.elements {
                moreSectionNavItems.append(SidebarItem.row(element: moreNavElement))
            }
            
            snapshot.append([sectionHeader])
            snapshot.expand([sectionHeader])
            snapshot.append(moreSectionNavItems, to: sectionHeader)
        }
        
        return snapshot
    }
    
    private func applyInitialSnapshot() {
        dataSource.apply(mainElementsSnapshot(), to: .main, animatingDifferences: false)
        dataSource.apply(moreElementsSnapshot(), to: .more, animatingDifferences: false)
    }
}

@available(iOS 14, *)
extension SidebarViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addToSiriAction(intent: INIntent) {
        if let shortcut = INShortcut(intent: intent) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.modalPresentationStyle = .formSheet
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - INUIAddVoiceShortcutViewControllerDelegate
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print("Added shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        print("Cancelled shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    func handleMainShortcut(_ index: Int) {
        self.shortcutToIndexPath(IndexPath(row: index, section: 0))
    }
    
    func handleOtherShortcut(_ keyboardShortcut: String) {
        var section = 1
        for otherNavSection in self.navigationData.moreSections {
            var row = 1 // Start at 1 because of the header element
            for otherNavElement in otherNavSection.elements {
                if let key = otherNavElement.keyboardShortcut {
                    if key == keyboardShortcut {
                        self.shortcutToIndexPath(IndexPath(row: row, section: section))
                        return
                    }
                }
                
                row += 1
            }
            
            section += 1
        }
    }
    
    private func shortcutToIndexPath(_ indexPath: IndexPath) {
        // Deselect the previously selected item
        if let currentIndexPath = collectionView.indexPathsForSelectedItems?.first {
            self.collectionView(self.collectionView, didDeselectItemAt: currentIndexPath)
        }
        
        // Then select the new cell
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        self.collectionView(self.collectionView, didSelectItemAt: indexPath)
    }
}
