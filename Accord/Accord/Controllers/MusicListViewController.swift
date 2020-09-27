//
//  MusicListViewController.swift
//  Accord
//
//  Created by Neestackich on 24.09.2020.
//

import UIKit

class MusicListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    // MARK: -Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewControllerId = "PlayerViewController"

    // var tracksList: [Track] = []
    
    // MARK: -Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 40
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        DatabaseManager.shared.getFirebaseTracks {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseManager.shared.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MusicTableViewCell") as! MusicTableViewCell
        tableViewCell.trackNameLabel.text?.append(DatabaseManager.shared.tracks[indexPath.row].trackName ?? "Unknown")
        tableViewCell.trackNameLabel.text?.append(" - ")
        tableViewCell.trackNameLabel.text?.append(DatabaseManager.shared.tracks[indexPath.row].author ?? "Unknown")
        tableViewCell.trackLengthLabel.text = DatabaseManager.shared.tracks[indexPath.row].length ?? "Unknown"
        tableViewCell.trackImage.image = UIImage(systemName: "music.note")
        
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playerViewController = storyboard?.instantiateViewController(withIdentifier: viewControllerId) as! PlayerViewController
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.trackName = DatabaseManager.shared.tracks[indexPath.row].trackName ?? "Unknown"
        playerViewController.author = DatabaseManager.shared.tracks[indexPath.row].author ?? "Unknown"
        
        present(playerViewController, animated: true)
    }
}
