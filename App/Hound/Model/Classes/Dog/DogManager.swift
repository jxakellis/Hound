//
//  DogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
        func copy(with zone: NSZone? = nil) -> Any {
            let copy = DogManager()
            for dog in dogs {
                if let dogCopy = dog.copy() as? Dog {
                    copy.dogs.append(dogCopy)
                }
            }
            return copy
        }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        dogs = aDecoder.decodeObject(forKey: KeyConstant.dogs.rawValue) as? [Dog] ?? dogs
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogs, forKey: KeyConstant.dogs.rawValue)
    }
    
    // MARK: - Main
    
    /// initalizes, sets dogs to []
    override init() {
        super.init()
    }
    
    /// Provide an array of dictionary literal of dog properties to instantiate dogs. Provide a dogManager to have the dogs add themselves into, update themselves in, or delete themselves from.
    convenience init?(forDogBodies dogBodies: [[String: Any]], overrideDogManager: DogManager?) {
        self.init()
        self.addDogs(forDogs: overrideDogManager?.dogs ?? [])
        
        for dogBody in dogBodies {
            let dogId: Int? = dogBody[KeyConstant.dogId.rawValue] as? Int
            let dogIsDeleted: Bool? = dogBody[KeyConstant.dogIsDeleted.rawValue] as? Bool
            
            guard let dogId = dogId, let dogIsDeleted = dogIsDeleted else {
                // couldn't construct essential components to intrepret dog
                continue
            }
            
            guard dogIsDeleted == false else {
                DogIconManager.removeIcon(forDogId: dogId)
                overrideDogManager?.removeDog(forDogId: dogId)
                continue
            }
            
            if let dog = Dog(forDogBody: dogBody, overrideDog: findDog(forDogId: dogId)) {
                addDog(forDog: dog)
            }
        }
    }
    
    /// Stores all the dogs. This is get only to make sure integrite of dogs added is kept
    private(set) var dogs: [Dog] = []
    
    /// Helper function allows us to use the same logic for addDog and addDogs and allows us to only sort at the end. Without this function, addDogs would invoke addDog repeadly and sortDogs() with each call.
    func addDogWithoutSorting(forDog newDog: Dog) {
        // If we discover a newDog has the same dogId as an existing dog, we remove
        dogs.removeAll { oldDog in
            return oldDog.dogId == newDog.dogId
        }
        
        dogs.append(newDog)
    }
    
    /// Adds a dog to dogs. If a dog with the same dogId already exists, combines that dog into newDog, then replaces dog with newDog.
    func addDog(forDog dog: Dog) {
        
        addDogWithoutSorting(forDog: dog)
        
        sortDogs()
    }
    
    /// Adds array of dogs with addDog(forDog: Dog) repition  (but only sorts once at the end to be more efficent)
    func addDogs(forDogs: [Dog]) {
        for dog in forDogs {
            addDogWithoutSorting(forDog: dog)
        }
        
        sortDogs()
    }
    
    /// Adds or updates a dog to dogs. If a dog with the same dogId already exists, doesn't combine that dog into newDog, simply just replaces dog with newDog.
    func updateDog(forDog updatedDog: Dog) {
        dogs.removeAll { oldDog in
            guard oldDog.dogId == updatedDog.dogId else {
                return false
            }
            // Don't combine oldDog into newDog, we are replacing for updateDog
            
            return true
        }
        
        dogs.append(updatedDog)
        sortDogs()
    }
    
    /// Sorts the dogs based upon their dogId
    private func sortDogs() {
        dogs.sort { dog1, dog2 in
            return dog1.dogId <= dog2.dogId
        }
    }
    
    /// Removes a dog with the given dogId
    func removeDog(forDogId dogId: Int) {
        // make sure we invalidate all the timers associated. this isn't technically necessary but its easier to tie up lose ends here
        if let dog = findDog(forDogId: dogId) {
            for reminder in dog.dogReminders.reminders {
                reminder.timer?.invalidate()
            }
        }
        
        dogs.removeAll { dog in
            return dog.dogId == dogId
        }
    }
    
}

extension DogManager {
    
    // MARK: Locate
    
    /// Returns reference of a dog with the given dogId
    func findDog(forDogId dogId: Int) -> Dog? {
        return dogs.first(where: { $0.dogId == dogId })
    }
    
    // MARK: Information
    
    /// Returns true if ANY the dogs present has at least 1 CREATED reminder
    var hasCreatedReminder: Bool {
        for dog in dogs where dog.dogReminders.reminders.count > 0 {
            return true
        }
        return false
    }
    
    /// Returns an array of tuples [(parentDogId, log]). This array has all the logs for all the dogs sorted chronologically, oldest log at index 0 and newest at end of array. Optionally filters by dictionary literal of [dogIds: [logActions]] provided
    private func logsByDogId(forLogsFilter logsFilter: [Int: [LogAction]], forMaximumNumberOfLogsPerDog maximumNumberOfLogsPerDog: Int) -> [Int: [Log]] {
        var logsByDogId: [Int: [Log]] = [:]
        
        // no filter was provided, so we add all logs of all dogs
        if logsFilter.isEmpty {
            for dog in dogs {
                logsByDogId[dog.dogId] = dog.dogLogs.logs.count > maximumNumberOfLogsPerDog
                ? Array(dog.dogLogs.logs[..<maximumNumberOfLogsPerDog])
                : dog.dogLogs.logs
            }
        }
        // a filter was provided
        else {
            // search for dogs provided in the filter, as we only want logs from dogs specified in the filter
            for dog in dogs where logsFilter.keys.contains(dog.dogId) {
                // search for dogLogs in the dog. We only want logs that have a logAction which is provided in the filter (under the dogId)
                var filteredDogLogs: [Log] = []
                for log in dog.dogLogs.logs {
                    // Stop the loop once we reach capacity
                    guard filteredDogLogs.count < maximumNumberOfLogsPerDog else {
                        break
                    }
                    
                    // the filter had the dogId stored, specifiying this dog, and had the logAction stored, specifying all logs of this logAction type. This means we can append the log
                    guard let logsFilter = logsFilter[dog.dogId], logsFilter.contains(log.logAction) else {
                        continue
                    }
                    
                    filteredDogLogs.append(log)
                }
                
                // No need to splice array as we know the array can't exceed the maximum specified
                logsByDogId[dog.dogId] = filteredDogLogs
            }
        }
        
        return logsByDogId
    }
    
    /// Returns an array of tuples [(uniqueDay, uniqueMonth, uniqueYear, [(parentDogId, log)])]. This array has all of the logs for all of the dogs grouped what unique day/month/year they occured on, first element is furthest in the future and last element is the oldest. Optionally filters by the dogId and logAction provides
    func groupedLogsByUniqueDate(forLogsFilter logsFilter: [Int: [LogAction]], forMaximumNumberOfLogsPerDog maximumNumberOfLogsPerDog: Int) -> [(Int, Int, Int, [(Int, Log)])] {
        // let startDate = Date()
        var dogIdLogsTuples: [(Int, Log)] = []
        // Put all the dogIds and logs into one array
        
        for element in logsByDogId(forLogsFilter: logsFilter, forMaximumNumberOfLogsPerDog: maximumNumberOfLogsPerDog) {
            element.value.forEach { log in
                dogIdLogsTuples.append((element.key, log))
            }
        }
        
        // let dogIdLogsTuplesCompiled = Date()
        
        // Sort this array chronologically (newest at index 0)
        dogIdLogsTuples.sort { tuple1, tuple2 in
            let (dogId1, log1) = tuple1
            let (dogId2, log2) = tuple2
            // If same logDate, then one with lesser dogId comes first
            guard log1.logDate != log2.logDate else {
                return dogId1 <= dogId2
            }
            
            // If the distance is less than zero, than means log1 is further in the future and log2 is further in the past
            return log1.logDate.distance(to: log2.logDate) <= 0
        }
        
        // Splice the sorted array so that it doesn't exceed maximumNumberOfLogsPerDog elements. This will be the maximumNumberOfLogsPerDog most recent logs as the array is sorted chronologically
        dogIdLogsTuples = dogIdLogsTuples.count > maximumNumberOfLogsPerDog
        ? Array(dogIdLogsTuples[..<maximumNumberOfLogsPerDog])
        : dogIdLogsTuples
        
        // let dogIdLogsTuplesSorted = Date()
        
        var groupedLogsByUniqueDate: [(Int, Int, Int, [(Int, Log)])] = []
        
        // we will be going from oldest logs to newest logs (by logDate)
        for element in dogIdLogsTuples {
            let logDay = Calendar.localCalendar.component(.day, from: element.1.logDate)
            let logMonth = Calendar.localCalendar.component(.month, from: element.1.logDate)
            let logYear = Calendar.localCalendar.component(.year, from: element.1.logDate)
            
            let containsDateCombination = groupedLogsByUniqueDate.contains { day, month, year, _ in
                // check to see if that day, month, year comboination is already present
                if day == logDay && month == logMonth && year == logYear {
                    return true
                }
                else {
                    return false
                }
            }
            
            // there is already a tuple with the same day, month, and year, so we want to add this dogId/log combo to the array attached to that tuple
            if containsDateCombination {
                groupedLogsByUniqueDate[groupedLogsByUniqueDate.count - 1].3.append(element)
                
            }
            // in the master array, there is not a matching tuple with the specified day, month, and year, so we should add an element that contains the day, month, and year plus this log since its logDate is on this day, month, and year
            else {
                groupedLogsByUniqueDate.append((logDay, logMonth, logYear, [element]))
            }
        }
        
        // let groupedLogsByUniqueDateCompiled = Date()
        
        // Sort the array so that the the tuples with the dates that are furthest in the future are at the beginning of the array and the oldest are at the end
        groupedLogsByUniqueDate.sort { tuple1, tuple2 in
            let (day1, month1, year1, _) = tuple1
            let (day2, month2, year2, _) = tuple2
            if year1 == year2 {
                if month1 == month2 {
                    // Tuple1's day is greater than Tuple2's days, meaning Tuple1 is further in the future and should come first
                    // we don't care if the days are equal as that case should never happen and, if it does, then the position doesn't matter
                    return day1 >= day2
                }
                else {
                    // Tuple1's month is greater than Tuple2's month, meaning Tuple1 is further in the future and should come first
                    return month1 >= month2
                }
            }
            else {
                // Tuple1's year is greater than Tuple2's year, meaning Tuple1 is further in the future and should come first
                return year1 >= year2
            }
        }
        
        return groupedLogsByUniqueDate
    }
}
