//
//  DocumentsViewController.swift
//  CoreDataSearch
//
//  Created by Steven Perrin on 9/30/19.
//  Copyright © 2019 Steven Perrin. All rights reserved.
//

import UIKit
import CoreData

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    @IBOutlet weak var documentsTableView: UITableView!
    let dateFormatter = DateFormatter()
    var documents = [Document]()
    var documentsFilter = [Document]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Documents"

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        createSearchController()
        self.documentsTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDocuments()
        documentsTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        fetchDocuments()
        documentsTableView.reloadData()
    }
    
    func createSearchController() {
        
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor(white: 0.8, alpha: 0.8)
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = false
        documentsTableView.tableHeaderView = searchController.searchBar
        
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
            (alertAction) -> Void in
            print("OK selected")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchDocuments() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        if (searchController.isActive == true && searchController.searchBar.text == "") || searchController.isActive == false {
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // order results by document name ascending
        
        do {
            documents = try managedContext.fetch(fetchRequest)
        } catch {
            alertNotifyUser(message: "Fetch for documents could not be performed.")
            return
        }
        }
        
        else {
            if let searchString = self.searchController.searchBar.text {
                fetchRequest.predicate = NSPredicate(format: "name contains[c] %@ || content contains[c] %@", searchString, searchString)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                
                do{
                    documentsFilter = try managedContext.fetch(fetchRequest)
                } catch {
                    alertNotifyUser(message: "Could not fetch documents")
                    return
                }
            }
        }
    }
    
    func deleteDocument(at indexPath: IndexPath) {
        let document = documents[indexPath.row]
        
        if let managedObjectContext = document.managedObjectContext {
            managedObjectContext.delete(document)
            
            do {
                try managedObjectContext.save()
                self.documents.remove(at: indexPath.row)
                documentsTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                alertNotifyUser(message: "Delete failed.")
                documentsTableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return documentsFilter.count
        }else{
             return documents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        if let cell = cell as? DocumentTableViewCell {
            var document = Document()
            if searchController.isActive == true && searchController.searchBar.text != "" {
                document = documentsFilter[indexPath.row]
            } else{
                 document = documents[indexPath.row]
            }
            
            cell.nameLabel.text = document.name
            cell.sizeLabel.text = String(document.size) + " bytes"
            
            if let modifiedDate = document.modifiedDate {
                cell.modifiedLabel.text = dateFormatter.string(from: modifiedDate)
            } else {
                cell.modifiedLabel.text = "unknown"
            }
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DocumentViewController,
           let segueIdentifier = segue.identifier, segueIdentifier == "existingDocument",
           let row = documentsTableView.indexPathForSelectedRow?.row {
            if searchController.isActive == true && searchController.searchBar.text == "" {
                destination.document = documents[row]
            }
                destination.document = documentsFilter[row]
        }
    }
    
    // There are two approaches to implementing deletion of table view cells.  Both are provided below.
    
    // Approach 1: using editing style
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(at: indexPath)
        }
    }
    
    /*
    // Approach 2: using editing actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
            action, index in
            self.deleteDocument(at: indexPath)  // self is required because inside of closure
        }
        
        return [delete]
    }
    */
 

}

