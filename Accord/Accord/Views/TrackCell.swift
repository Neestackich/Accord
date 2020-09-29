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
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var trackLengthLabel: UILabel!
    @IBOutlet weak var downloadProgressButton: UIView!
    @IBOutlet weak var downloadButtonImage: UIImageView!
    @IBOutlet weak var downloadProgressImage: UIImageView!
    @IBOutlet weak var downloadProgressLine: UIProgressView!
    
    // var url: String?
    var track: Track?
    // var trackIndex: Int?
    var circleLoadingStatus: CAShapeLayer!
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
        
        circleLoadingStatus = CAShapeLayer()
        circleLoadingStatus.path = circularPath.cgPath
        circleLoadingStatus.strokeColor = UIColor.white.cgColor
        circleLoadingStatus.fillColor = UIColor.clear.cgColor
        circleLoadingStatus.lineWidth = 5
        
        cellView.layer.cornerRadius = 40
        cellView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        trackImage.layer.cornerRadius = 40
        trackImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        downloadButton.layer.cornerRadius = 28
        downloadButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        downloadProgressButton.layer.cornerRadius = 30
        
        cellView.layer.addSublayer(circleLoadingStatus)
        
        downloadProgressButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadTap)))
    }
    
    func updateCell(progress: Float) {
        downloadProgressLine.progress = progress
    }
    
    func configereCell(track: Track) {
        self.track = track
        
        trackNameLabel.text =
            (track.trackName ?? "Unknown")
            + " - "
            + (track.author ?? "Unknown")
        trackLengthLabel.text = track.length ?? "Unknown"
        trackImage.image = UIImage(systemName: "music.note")
        // updateCell(progress: )
    }
    
    
    // MARK: -Networking
    
    @objc func downloadTap() {
        switch downloadStatus {
        case .unactiveDownload:
            downloadStatus = .activeDownload
            downloadButtonImage.image = UIImage(systemName: "pause")
            
            if let track = track {
                let index = Int(track.index)
                
                if let url = track.url {
                    URLSessionManager.shared.startDownload(url: url, trackIndex: index)
                }
            }
        case .activeDownload:
            downloadStatus = .pausedDownload
            downloadButtonImage.image = UIImage(systemName: "arrow.down")
            
            if let track = track {
                if let url = track.url {
                    URLSessionManager.shared.pauseDownload(url: url)
                }
            }
        case .pausedDownload:
            downloadStatus = .activeDownload
            downloadButtonImage.image = UIImage(systemName: "pause")
            
            if let track = track {
                if let url = track.url {
                    URLSessionManager.shared.resumeDownload(url: url)
                }
            }
        }
    }
}
