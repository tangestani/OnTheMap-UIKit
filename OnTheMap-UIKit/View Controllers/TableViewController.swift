//
//  TableViewController.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/17/20.
//

import UIKit

class TableViewController: UITableViewController, StudentLocationsViewer {
    var locations = [StudentLocation]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Student Location Cell", for: indexPath)
        let location = locations[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = location.name
        content.secondaryText = location.mediaURL
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(named: "icon_pin")
        
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString: String = locations[indexPath.row].mediaURL
        guard var components = URLComponents(string: urlString) else { return }
        if components.scheme != "http" && components.scheme != "https" {
            // Use https if the url is missing a valid HTTP scheme
            components.scheme = "https"
        }
        guard let url = components.url else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
