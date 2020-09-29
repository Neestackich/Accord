//
//  Download+CoreDataProperties.swift
//  
//
//  Created by Neestackich on 29.09.2020.
//
//

import Foundation
import CoreData


extension Download {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Download> {
        return NSFetchRequest<Download>(entityName: "Download")
    }

    @NSManaged public var isDownloading: Bool
    @NSManaged public var progress: Float
    @NSManaged public var resumeData: Data?
    @NSManaged public var pathToDownloadFile: URL?
    @NSManaged public var downloaded: Bool
    @NSManaged public var url: URL?
    @NSManaged public var trackIndex: Int64
    @NSManaged public var task: NSObject?

}
