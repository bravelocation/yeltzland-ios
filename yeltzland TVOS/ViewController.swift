//
//  ViewController.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var fixturesTableView: UITableView!
    
    let dataSource:TVDataSource = TVDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fixturesTableView.delegate = self
        self.fixturesTableView.dataSource = self.dataSource
        
        self.view.backgroundColor = AppColors.TVBackground
        
        // TODO: Setup notification handlers
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.TVBackground
        header.textLabel!.textColor = AppColors.TVHeaderText
        header.textLabel!.font = UIFont.preferredFont(forTextStyle: .headline)
        header.textLabel?.text = self.dataSource.headerText(section: section)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.contentView.backgroundColor = AppColors.TVBackground
        footer.textLabel!.textColor = AppColors.TVText
        footer.textLabel!.font = UIFont.preferredFont(forTextStyle: .headline)
        footer.textLabel?.text = self.dataSource.footerText(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let footerText = self.dataSource.footerText(section: section)
        
        if (footerText.count > 0) {
            return 66.0
        }
        
        return 0.0
    }
}

