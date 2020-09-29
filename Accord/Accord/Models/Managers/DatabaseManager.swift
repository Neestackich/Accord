//
//  DatabaseManager.swift
//  Accord
//
//  Created by Neestackich on 24.09.2020.
//

import UIKit
import CoreData
import FirebaseFirestore

class DatabaseManager {
    
    
    // MARK: -Properties
    
    static let shared = DatabaseManager()
    var tracks: [Track] = []
    
    // MARK: -Methods
    
    func getFirebaseTracks(action: (() -> Void)!) {
        if coreDataIsEmpty() {
            let firestoreDatabase = Firestore.firestore()
            firestoreDatabase.collection("tracks").getDocuments { documents, error in
                if let error = error {
                    
                    // обработать ошибку !!!
                    print("Get firebase tracks error")
                    
                } else {
                    if let documents = documents {
                        for (index, document) in documents.documents.enumerated() {
                            DatabaseManager.shared.addFirebaseTracksToCoreData(
                                trackName: document.data()["trackName"] as! String,
                                author: document.data()["author"] as! String,
                                length: document.data()["length"] as! String,
                                url: document.data()["url"] as! String,
                                index: Int64(index))
                            print(index)
                            
                            print(document.data()["trackName"] as! String)
                            print(document.data()["url"] as! String)
                        }
                        
                        self.tracks = DatabaseManager.shared.getCoreDataTracks()
                        
                        if action != nil {
                            action()
                        }
                    }
                }
            }
        } else {
            self.tracks = DatabaseManager.shared.getCoreDataTracks()
            
            if action != nil {
                action()
            }

        }
    }
    
    func coreDataIsEmpty() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        
        do {
            if try context.count(for: fetchRequest) != 0 {
                return false
            }
        } catch {
            print("Count error")
        }
        
        return true
    }
    
    func addFirebaseTracksToCoreData(trackName: String, author: String, length: String, url: String, index: Int64) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Track", in: context)
        
        if let entity = entity {
            let track = NSManagedObject(entity: entity, insertInto: context) as! Track
            track.trackName = trackName
            track.author = author
            track.length = length
            track.url = url
            track.index = index
            
            do {
                try context.save()
                print("New object '\(trackName)' saved")
            } catch {
                print("Save error")
            }
        }
    }
    
    func getCoreDataTracks() -> [Track] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fetch error")
        }
        
        return []
    }
    
//    func getCoreDataDownloads() -> [Download] {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        let fetchRequest: NSFetchRequest<Download> = Download.fetchRequest()
//
//        do {
//            return try context.fetch(fetchRequest)
//        } catch {
//            print("Fetch error")
//        }
//
//        return []
//    }
    
    func coreDataCleanUp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        for track in tracks {
            do {
                try context.delete(track)
            } catch {
                print("Delete error")
            }
        }
    }
}
