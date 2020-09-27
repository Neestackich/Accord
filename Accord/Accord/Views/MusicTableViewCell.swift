//
//  MusicTableViewCell.swift
//  Accord
//
//  Created by Neestackich on 24.09.2020.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

    
    // MARK: -Properties
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var trackLengthLabel: UILabel!
    
    @IBOutlet weak var downloadProgressImage: UIImageView!
    @IBOutlet weak var downloadProgressButton: UIView!
    
    var circleLoadingStatus: CAShapeLayer!
    
    // MARK: -Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 40
        cellView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        trackImage.layer.cornerRadius = 40
        trackImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        downloadButton.layer.cornerRadius = 28
        downloadButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        downloadProgressButton.layer.cornerRadius = 30
        
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup() {
        downloadProgressButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadTap)))
        
        
        circleLoadingStatus = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: downloadProgressButton.center, radius: 30, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)

        circleLoadingStatus.path = circularPath.cgPath
        circleLoadingStatus.strokeColor = UIColor.white.cgColor
        circleLoadingStatus.fillColor = UIColor.clear.cgColor
        circleLoadingStatus.lineWidth = 5
        
        cellView.layer.addSublayer(circleLoadingStatus)
        // downloadProgressButton.layer.addSublayer(circleLoadingStatus)
    }
    
    @objc func downloadTap() {
        print("tap")
    }
}
