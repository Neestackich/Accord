//
//  PlayerViewController.swift
//  Accord
//
//  Created by Neestackich on 24.09.2020.
//

import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    
    // MARK: -Properties
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var forwardRewind: UIButton!
    @IBOutlet weak var backwardRewind: UIButton!
    @IBOutlet weak var controllButtonsBackgroundView: UIView!
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var currentTrackTime: UILabel!
    @IBOutlet weak var mainTrackTime: UILabel!
    @IBOutlet weak var playerTrackControllers: UIStackView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var playerTrackButtons: UIStackView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var track: Track?
    var player: AVAudioPlayer?
    var isTrackPlaying = false
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var delegate: TrackListViewControllerDelegate?
    
    
    // MARK: -Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        if let track = track {
            if let author = track.author, let trackName = track.trackName {
                authorLabel.text = author
                trackNameLabel.text = trackName
                
                //put trackImage here
            }
            
            if let url = track.url, let sourceUrl = URL(string: url) {
                if let download = URLSessionManager.shared.activeDownloads[sourceUrl] {
                    if download.downloadStatus != .pausedDownload {
                        warningLabel.isHidden = true
                    } else {
                        showControllers()  
                    }
                } else {
                    showControllers()
                }
            }
        }
                
        configureAudioPlayer()
        viewsCornersSetup(views: mainView, controllerView, blankView)
        buttonsSetup(buttons: playButton, backButton, backwardRewind, forwardRewind, deleteButton)
        
        var timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSelector), userInfo: nil, repeats: true)
    }
    
    func showControllers() {
        warningLabel.isHidden = false
        playerTrackButtons.isHidden = true
        playerTrackControllers.isHidden = true
        deleteButton.isHidden = true
    }
    
    func viewsCornersSetup(views: UIView...) {
        for singleView in views {
            singleView.layer.cornerRadius = 50
            singleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func buttonsSetup(buttons: UIButton...) {
        for button in buttons {
            button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    func configureAudioPlayer() {
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            guard let track = track, let url = track.url, let unwrappedUrl = URL(string: url) else {
                return
            }
            
            player = try AVAudioPlayer(contentsOf: localFilePath(for: unwrappedUrl))
            
            guard let player = player else {
               return
            }
            
            trackSlider.maximumValue = Float(player.duration)
            mainTrackTime.text = "0:30"
        } catch {
            
        }
    }
    
    func setGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = mainView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.systemGreen.cgColor]
        mainView.layer.addSublayer(gradientLayer)
    }
    
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    @IBAction func deleteButtonClick(_ sender: Any) {
        guard let track = track, let url = track.url, let sourceURL = URL(string: url) else {
            return
        }
        
        guard let player = player else {
            return
        }
        
        let fileManager = FileManager.default
        let destinationUrl = localFilePath(for: sourceURL)
        
        do {
            try fileManager.removeItem(at: destinationUrl)
            deleteButton.isHidden = true
            print("Removed by path: \(destinationUrl)")
        } catch {
            print("No items found \(destinationUrl)")
        }
        
        player.stop()
        configureAudioPlayer()
        warningLabel.isHidden = false
        playerTrackButtons.isHidden = true
        playerTrackControllers.isHidden = true
        
        URLSessionManager.shared.activeDownloads[sourceURL] = nil
        
        delegate?.updateCell(row: Int(track.index))
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        guard let player = player else {
            return
        }
        
        player.pause()
    }
    
    @IBAction func playButtonClick(_ sender: Any) {
        guard let player = player else {
            return
        }
        
        if isTrackPlaying {
            player.pause()
            
            isTrackPlaying = false
            
            currentTrackTime.text = String(player.currentTime)
        } else {
            player.play()
            
            isTrackPlaying = true
        }
        
        updateButton()
    }
    
    @IBAction func changeTrackDuration(_ sender: Any) {
        guard let player = player else {
            return
        }
    
        player.currentTime = TimeInterval(trackSlider.value)
    }
    
    @objc func updateSelector() {
        guard let player = player  else {
            return
        }
        
        trackSlider.value = Float(player.currentTime)
        currentTrackTime.text = String(Int(player.currentTime))
        
        if player.currentTime == player.duration {
            isTrackPlaying = false
            updateButton()
        }
    }
    
    func updateButton() {
        if isTrackPlaying {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
}
