//
//  TrackCellDelegate.swift
//  Accord
//
//  Created by Neestackich on 28.09.2020.
//

import Foundation

protocol TrackCellDelegate {
    func startDownload(cell: TrackCell)
    func pauseDownload(cell: TrackCell)
    func resumeDownload(cell: TrackCell)
}
