//
//  MusicListViewController.swift
//  Accord
//
//  Created by Neestackich on 24.09.2020.
//

import UIKit


class TracksListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDownloadDelegate, TrackCellDelegate, TrackListViewControllerDelegate {
    

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
    
    func updateCell(row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseManager.shared.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        tableViewCell.configereCell(track: DatabaseManager.shared.tracks[indexPath.row], delegate: self, indexPath: indexPath)
        
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playerViewController = storyboard?.instantiateViewController(withIdentifier: viewControllerId) as! PlayerViewController
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.track = DatabaseManager.shared.tracks[indexPath.row]
        playerViewController.delegate = self
        
        present(playerViewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: -Networkng
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        if let sourceURL = downloadTask.originalRequest?.url {
            guard let download = URLSessionManager.shared.activeDownloads[sourceURL] else {
                return
            }
            
            // URLSessionManager.shared.activeDownloads[sourceURL] = nil

            guard let url = URL(string: download.url) else {
                return
            }
            
            let destinationURL = localFilePath(for: sourceURL)
            print(destinationURL)
            
            let fileManager = FileManager.default
            try? fileManager.removeItem(at: destinationURL)
            
            do {
                try fileManager.copyItem(at: location, to: destinationURL)
                download.isDownloaded = true
                download.downloadStatus = .finishedDownload
                
                DatabaseManager.shared.addDownloadedTrackToCoreData(
                    trackIndex: download.trackIndex,
                    downloadedTrackPath: url,
                    resumeData: download.resumeData,
                    isDownloading: false,
                    isDownloaded: true,
                    progress: download.progress,
                    url: url)
            } catch let error {
              print("Could not copy file to disk: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.trackIndex, section: 0)) as? TrackCell {
                    trackCell.hideDownloadButton()
                    self.tableView.reloadRows(at: [IndexPath(row: download.trackIndex, section: 0)], with: .none)
                }
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
   
    
    // MARK: -TrackCellDelegate
    
    func startDownload(cell: TrackCell) {
        updateCell(row: Int(cell.track?.index ?? 0))
    }
    
    func pauseDownload(cell: TrackCell) {
        updateCell(row: Int(cell.track?.index ?? 0))
    }
    
    func resumeDownload(cell: TrackCell) {
        updateCell(row: Int(cell.track?.index ?? 0))
    }
}
