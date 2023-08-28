//
//  ViewController.swift
//  Project7
//
//  Created by Guga Dolidze on 8/27/23.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]() // Add this property
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showAlert))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterArray))
        
        // Determine the URL based on tab bar selection
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        // Fetch and parse JSON data from URL
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        // Display error if data fetch fails
        showError()
    }
    
    // MARK: - Alert Actions
    
    @objc func showAlert() {
        // Display information alert about data source
        let ac = UIAlertController(title: "Info", message: "The data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func filterArray() {
        // Display an alert with a text field for filtering petitions
        let alertController = UIAlertController(title: "Filter Petitions", message: "Enter keywords to filter petitions:", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter keywords"
        }

        // Filter action based on user input
        let filterAction = UIAlertAction(title: "Filter", style: .default) { [weak self, weak alertController] _ in
            guard let self = self, let alertController = alertController else { return }
            
            if let searchText = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
                // Filter petitions based on search text
                self.filteredPetitions = self.petitions.filter { petition in
                    return petition.title.lowercased().contains(searchText.lowercased()) ||
                           petition.body.lowercased().contains(searchText.lowercased())
                }
            } else {
                // Reset filter if search text is empty
                self.filteredPetitions = self.petitions
            }
            
            // Update table view with filtered data
            self.tableView.reloadData()
        }

        // Cancel action for filtering
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(filterAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Data Parsing
    
    func parse(json: Data) {
        // Decode JSON data into Petitions object and populate petitions array
        let decoder = JSONDecoder()
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    // MARK: - Table View Data Source and Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows based on filtered petitions
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure table view cells with filtered petition data
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Display detail view when a row is selected
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Error Handling
    
    func showError() {
        // Display error alert when data loading fails
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}



