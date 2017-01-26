//
//  ViewController.swift
//  KVRefreshable
//
//  Created by Vu Van Khac on 01/26/2017.
//  Copyright (c) 2017 Vu Van Khac. All rights reserved.
//

import UIKit
import KVRefreshable

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var allObjects: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allObjects = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
        tableView.addInfiniteScrollingWithActionHandler {
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.tableView.beginUpdates()
                self.allObjects.append("")
                self.tableView.insertRows(at: [IndexPath(row: self.allObjects.count - 1, section: 0)], with: .fade)
                self.tableView.endUpdates()
                self.tableView.infiniteScrollingView?.stopAnimating()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDataSource
    @objc(tableView:numberOfRowsInSection:) func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allObjects.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc(tableView:estimatedHeightForRowAtIndexPath:) func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}

