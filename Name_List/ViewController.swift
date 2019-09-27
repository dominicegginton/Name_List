//
//  ViewController.swift
//  Name_List
//
//  Created by Dominic Egginton on 27/09/2019.
//  Copyright © 2019 Dominic Egginton. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Name List"
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelagate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelagate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            self.people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @IBAction func addName(_ sender: Any) {
        let addNameAlert = UIAlertController(title: "Add Nmae", message: "Add a new name to your list", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save Name", style: .default, handler: { [unowned self] action in
            guard let addNameTextFeild = addNameAlert.textFields?.first, let newName = addNameTextFeild.text else {
                return
            }
            self.save(newName)
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title:"Cancle", style: .cancel)
        
        addNameAlert.addTextField()
        addNameAlert.addAction(saveAction)
        addNameAlert.addAction(cancelAction)
        
        present(addNameAlert, animated: true)
    }
    
    func save(_ newName: String) {
        guard let appDelagate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelagate.persistentContainer.viewContext
        let entry = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entry, insertInto: managedContext)
        person.setValue(newName, forKey: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch {
            print("Could not save. \(error)")
        }
    }
    
}

//MARK: -UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let person = self.people[indexPath.row]
        
        
        cell.textLabel?.text = person.value(forKey: "name") as? String
        return cell
    }
    
}
