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
        
        func elementImage() -> UIImage? {
            var itemImage: UIImage?
            if let imageName = self.element.imageName {
                itemImage = UIImage(named: imageName)?.sd_tintedImage(with: UIColor(named: "blue-tint")!)
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureCollectionView()
        self.configureDataSource()
        self.applyInitialSnapshot()
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
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
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    private func updateDetailViewController(controller: UIViewController) {
        if let splitViewController = self.splitViewController {
            splitViewController.showDetailViewController(controller, sender: nil)
        }
    }
    
    private func didSelectItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
        switch sidebarItem.element.type {
        case .controller(let viewController):
            self.updateDetailViewController(controller: viewController)
            return 
        case .siri(let intent):
            // TODO(JP): Load the appropriate controller
            // self.addToSiriAction(intent: intent)
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
}

@available(iOS 14, *)
extension SidebarViewController {
    private func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, _, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.element.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            contentConfiguration.textProperties.color = .secondaryLabel
            
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure()]
        }
        
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, _, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
            contentConfiguration.text = item.element.title
            contentConfiguration.secondaryText = item.element.subtitle
            contentConfiguration.image = item.elementImage()
            
            cell.contentConfiguration = contentConfiguration
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
    
    private func mainElementsSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        
        var mainNavItems: [SidebarItem] = []
        for mainNavElement in self.navigationData.mainSection.elements {
            mainNavItems.append(SidebarItem.row(element: mainNavElement))
        }
            
        snapshot.append(mainNavItems)
        
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
