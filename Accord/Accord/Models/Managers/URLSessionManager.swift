//
//  URLSessionManager.swift
//  Accord
//
//  Created by Neestackich on 27.09.2020.
//

import UIKit
import CoreData

class URLSessionManager {
    
    
    // MARK: -Properties
    
    static let shared = URLSessionManager()
    
    var activeDownloads: [URL: Download] = [:]
    var downloadSession: URLSession?
    
    
    // MARK: -Methods
    
    func startDownload(url: String, trackIndex: Int) {
        let download = Download(url: url, trackIndex: trackIndex)

        download.url = url
        download.trackIndex = trackIndex
        
        if let urlU = URL(string: url) {
            download.task = downloadSession?.downloadTask(with: urlU)
            download.task?.resume()
            download.isDownloading = true
            download.downloadStatus = .activeDownload
            activeDownloads[urlU] = download
        }
    }
    
    func cancelDownload(url: String) {
        if let url = URL(string: url) {
            if let download = activeDownloads[url], download.isDownloading {
                download.task?.cancel()
                download.downloadStatus = .finishedDownload
                activeDownloads[url] = nil
            }
        }
    }
    
    func pauseDownload(url: String) {
        if let url = URL(string: url) {
            if let download = activeDownloads[url], download.isDownloading {
                download.task?.cancel { data in
                    download.resumeData = data
                }
                download.downloadStatus = .pausedDownload
                download.isDownloading = false
            }
        }
    }
    
    func resumeDownload(url: String) {
        if let url = URL(string: url) {
            if let download = activeDownloads[url] {
                if let resumeData = download.resumeData {
                    print(resumeData)
                    download.task = downloadSession?.downloadTask(withResumeData: resumeData)
                    print("Resumed")
                } else {
                    download.task = downloadSession?.downloadTask(with: url)
                    print("Cant be resumed ")
                }
                
                download.downloadStatus = .activeDownload
                download.task?.resume()
                download.isDownloading = true
            }
        }
    }
}
