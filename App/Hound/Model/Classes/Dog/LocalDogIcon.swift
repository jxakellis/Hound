//
//  LocalDogIcon.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LocalDogIcon {
    // MARK: - Main
    
    init(forDogId dogId: Int, forDogIcon dogIcon: UIImage) {
        self.dogId = dogId
        self.dogIcon = dogIcon
    }
    
    // MARK: - Properties
    
    var dogId: Int = ClassConstant.DogConstant.defaultDogId
    var dogIcon: UIImage = ClassConstant.DogConstant.defaultDogIcon
    
    // MARK: - Functions
    
    /// Attempts to create a file path url for the given dogId
    private static func getIconURL(forDogId dogId: Int) -> URL? {
        // make sure we have a urls to read/write to
        let documentsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // create URL
        guard let url = documentsURLs.first?.appendingPathComponent("dog\(dogId).png") else {
            return nil
        }
        
        return url
    }
    
    /// Attempts to retrieve the dogIcon for the provided dogId. If no dogIcon is found, then nil is returned
    static func getIcon(forDogId dogId: Int) -> UIImage? {
        // need a url to perform any read/writes to
        guard let url = getIconURL(forDogId: dogId) else {
            return nil
        }
        
        // attempt to find and return image
        return UIImage(contentsOfFile: url.path)
    }
    
    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogId, then adds a LocalDogIcon to LocalConfiguration.dogIcons with the provided dogId and dogIcon.
    static func addIcon(forDogId dogId: Int, forDogIcon dogIcon: UIImage) {
        
        removeIcon(forDogId: dogId)
        
        // need a url to perform any read/writes to
        guard let url = getIconURL(forDogId: dogId) else {
            return
        }
        
        // convert dogIcon to data, then attempt to write to url, saving the image
        try? dogIcon.pngData()?.write(to: url)
    }
    
    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogId
    static func removeIcon(forDogId dogId: Int) {
        // need a url to perform any read/writes to
        guard let url = getIconURL(forDogId: dogId) else {
            return
        }
        
        // attempt to remove any image at specified url
        try? FileManager.default.removeItem(at: url)
    }
    
}
