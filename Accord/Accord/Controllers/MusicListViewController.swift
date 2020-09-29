//
//  MusicListViewController.swift
//  Accord
//
//  Created by Neestackich on 24.09.2020.
//

import UIKit

class MusicListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDownloadDelegate {
    
    
    // MARK: -Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let viewControllerId = "PlayerViewController"
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "AccordDownloads")
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    
    // MARK: -Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLSessionManager.shared.downloadSession = downloadSession
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 40
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        DatabaseManager.shared.getFirebaseTracks {
            self.tableView.reloadData()
        }
    }
    
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseManager.shared.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MusicTableViewCell", for: indexPath) as! TrackCell
        tableViewCell.configereCell(track: DatabaseManager.shared.tracks[indexPath.row])

        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playerViewController = storyboard?.instantiateViewController(withIdentifier: viewControllerId) as! PlayerViewController
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.trackName = DatabaseManager.shared.tracks[indexPath.row].trackName ?? "Unknown"
        playerViewController.author = DatabaseManager.shared.tracks[indexPath.row].author ?? "Unknown"
        
        present(playerViewController, animated: true)
    }
    
    
    // MARK: -Networkng
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        if let sourceURL = downloadTask.originalRequest?.url {
            let download = URLSessionManager.shared.activeDownloads[sourceURL]
            URLSessionManager.shared.activeDownloads[sourceURL] = nil
            
            let destinationURL = localFilePath(for: sourceURL)
            print(destinationURL)
            
            let fileManager = FileManager.default
            try? fileManager.removeItem(at: destinationURL)
            
            do {
              try fileManager.copyItem(at: location, to: destinationURL)
              download?.downloaded = true
            } catch let error {
              print("Could not copy file to disk: \(error.localizedDescription)")
            }
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if let url = downloadTask.originalRequest?.url, let download = URLSessionManager.shared.activeDownloads[url] {
            download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            DispatchQueue.main.async {
                if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.trackIndex, section: 0)) as? TrackCell {
                    trackCell.updateCell(progress: download.progress)
                    print(download.progress)
                }
            }
        }
    }
}
