//
//  Download.swift
//  Accord
//
//  Created by Neestackich on 29.09.2020.
//

import Foundation


class Download {
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var trackIndex: Int
    var url: String
    var downloaded = false
  
    init(url: String, trackIndex: Int) {
        self.url = url
        self.trackIndex = trackIndex
  }
}
