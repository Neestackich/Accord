//
//  Downloads+CoreDataProperties.swift
//  
//
//  Created by Neestackich on 30.09.2020.
//
//

import Foundation
import CoreData


extension Downloads {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Downloads> {
        return NSFetchRequest<Downloads>(entityName: "Downloads")
    }

    @NSManaged public var downloadedTrackPath: URL?
    @NSManaged public var isDownloaded: Bool
    @NSManaged public var isDownloading: Bool
    @NSManaged public var progress: Float
    @NSManaged public var resumeData: Data?
    @NSManaged public var task: NSObject?
    @NSManaged public var trackIndex: Int64
    @NSManaged public var url: URL?

}
