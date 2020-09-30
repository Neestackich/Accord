//
//  MusicTableViewCell.swift
//  Accord
//
//  Created by Neestackich on 24.09.2020.
//

import UIKit

class TrackCell: UITableViewCell {

    
    // MARK: -Properties
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackLengthLabel: UILabel!
    @IBOutlet weak var downloadProgressButton: UIView!
    @IBOutlet weak var downloadButtonImage: UIImageView!
    @IBOutlet weak var downloadProgressLine: UIProgressView!
    
    var track: Track?
//    var circleLoadingStatus: CAShapeLayer!
    var downloadStatus: DownloadProgress = .unactiveDownload
    
    var delegate: TrackCellDelegate?
    
    
    // MARK: -Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup() {
        let circularPath = UIBezierPath(
            arcCenter: downloadProgressButton.center,
            radius: 30,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true)
        
//        circleLoadingStatus = CAShapeLayer()
//        circleLoadingStatus.path = circularPath.cgPath
//        circleLoadingStatus.strokeColor = UIColor.white.cgColor
//        circleLoadingStatus.fillColor = UIColor.clear.cgColor
//        circleLoadingStatus.lineWidth = 5
        
        cellView.layer.cornerRadius = 40
        cellView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        trackImage.layer.cornerRadius = 40
        trackImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        downloadProgressButton.layer.cornerRadius = 30
        
//      cellView.layer.addSublayer(circleLoadingStatus)
        
        downloadProgressButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadTap)))
    }
    
    func updateCell(progress: Float) {
        downloadProgressLine.progress = progress
    }
    
    func hideDownloadButton() {
        downloadButtonImage.isHidden = true
        downloadProgressButton.isHidden = true
    }
    
    func showDownloadButton() {
        downloadButtonImage.isHidden = false
        downloadProgressButton.isHidden = false
    }
    
    func configereCell(track: Track, delegate: TrackCellDelegate, indexPath: IndexPath) {
        var downloadProgress: Float = 0
        
        self.downloadStatus = .unactiveDownload
        self.track = track
        self.delegate = delegate
        
        trackNameLabel.text =
            (track.trackName ?? "Unknown")
            + " - "
            + (track.author ?? "Unknown")
        trackLengthLabel.text = track.length ?? "Unknown"
        trackImage.image = UIImage(systemName: "music.note")
        
        guard let unwrappedUrl = track.url, let url = URL(string: unwrappedUrl) else {
            return
        }
        
        if let download = URLSessionManager.shared.activeDownloads[url] {
            downloadProgress = download.progress
            downloadStatus = download.downloadStatus
            
            print(download.progress)
        }
        
        updateCell(progress: downloadProgress)
        
        switch downloadStatus {
        case .activeDownload:
            showDownloadButton()
            downloadButtonImage.image = UIImage(systemName: "pause")
        case .unactiveDownload:
            showDownloadButton()
            downloadButtonImage.image = UIImage(systemName: "arrow.down")
        case .pausedDownload:
            showDownloadButton()
            downloadButtonImage.image = UIImage(systemName: "arrow.down")
        case .finishedDownload:
            hideDownloadButton()
        }
    }
    
    
    // MARK: -Networking
    
    @objc func downloadTap() {
        switch downloadStatus {
        case .unactiveDownload:
            downloadStatus = .activeDownload
            
            if let track = track {
                let index = Int(track.index)
                
                if let url = track.url {
                    URLSessionManager.shared.startDownload(url: url, trackIndex: index)
                }
            }
            
            delegate?.startDownload(cell: self)
        case .activeDownload:
            downloadStatus = .pausedDownload
            
            if let track = track {
                if let url = track.url {
                    URLSessionManager.shared.pauseDownload(url: url)
                }
            }
            
            delegate?.pauseDownload(cell: self)
        case .pausedDownload:
            downloadStatus = .activeDownload
            
            if let track = track {
                if let url = track.url {
                    URLSessionManager.shared.resumeDownload(url: url)
                }
            }
            
            delegate?.resumeDownload(cell: self)
        case .finishedDownload:
            break
        }
    }
}
