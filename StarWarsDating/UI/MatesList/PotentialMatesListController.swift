//
//  PotentialMatesListController.swift
//  StarWarsDating
//
//  Created by Devin Pitcher on 8/1/19.
//  Copyright © 2019 FreshProduce LLC. All rights reserved.
//
//  PotentialMatesListController is the root controller of the app. It's tableview is
//  populated with PotentialMates.

import UIKit

class PotentialMatesListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var mates = [PotentialMate]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleMatesRefreshed), name: PotentialMatesStore.potoentialMatesRefreshedNotif, object: PotentialMatesStore.sharedInstance)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = PotentialMatesListCell.cellHeight
        tableView.register(PotentialMatesListCell.self, forCellReuseIdentifier: PotentialMatesListCell.cellID)
        
        mates = PotentialMatesStore.sharedInstance.getAllMates()
    }

    @objc private func handleMatesRefreshed() {
        mates = PotentialMatesStore.sharedInstance.getAllMates()
        tableView.reloadData()
    }
}


extension PotentialMatesListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Singles of the Day:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PotentialMatesListCell.cellID, for: indexPath) as! PotentialMatesListCell
        let mate = mates[indexPath.row]
        cell.mate = mate
        return cell
    }
    
}

extension PotentialMatesListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = .white
        
        let lab = UILabel()
        header.addSubview(lab)
        lab.text = self.tableView(tableView, titleForHeaderInSection: section)
        lab.textColor = StarWarsConsts.primaryTextColor
        lab.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.centerXAnchor.constraint(equalTo: header.centerXAnchor).isActive = true
        lab.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -10).isActive = true
        
        let sep = UIView()
        header.addSubview(sep)
        sep.backgroundColor = tableView.separatorColor
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        sep.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        sep.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        sep.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mate = mates[indexPath.row]
        let detailsController = PotentialMateDetailsController(with: mate)
        self.present(detailsController, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

