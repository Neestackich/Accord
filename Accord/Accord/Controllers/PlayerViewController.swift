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
    
    var track: Track?
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var player: AVAudioPlayer?
    var isTrackPlaying = false
    
    // MARK: -Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let track = track {
            if let author = track.author, let trackName = track.trackName {
                authorLabel.text = author
                trackNameLabel.text = trackName
            }
        }
    }
    
    func setup() {
        mainView.layer.cornerRadius = 50
        mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        controllerView.layer.cornerRadius = 50
        controllerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        blankView.layer.cornerRadius = 50
        blankView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        playButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backwardRewind.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        forwardRewind.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
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
        
        var timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSelector), userInfo: nil, repeats: true)
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
    }
    
    func updateButton() {
        if isTrackPlaying {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
}
