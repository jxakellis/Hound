//
//  DogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TO DO BUG PRIO: LOW reminders and logs disappearing. Happens primarily when involved with other users / when sourced from other users. Typically disppears with lifecycle, e.g. goes to background then opens later and its missing.
// For example: the new log/reminder is synced to the device, so the server won't return it anymore. Then it appears the new log/reminder isn't persisted so when the user opens the app again, the new log/reminder is missing. The issue can be solved by hitting Redownload Data
final class DogManager: NSObject, NSCopying, NSCoding {
    
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
        dogs = aDecoder.decodeObject(forKey: "dogs") as? [Dog] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogs, forKey: "dogs")
    }
    
    // MARK: - Main
    
    /// initalizes, sets dogs to []
    override init() {
        super.init()
    }
    
    convenience init(forDogs dogs: [Dog]) {
        self.init()
        // verifys dogs and fixes if broken
        self.addDogs(forDogs: dogs)
    }
    
    /// Init from an array of dog JSON
    convenience init?(fromBody dogBodies: [[String: Any]]) {
        var dogArray: [Dog] = []
        
        // Array of dog JSON [{dog1:'foo'},{dog2:'bar'}]
        for dogBody in dogBodies {
            let dog = Dog(fromBody: dogBody)
            // If we have an image stored locally for a dog, then we apply the icon.
            // If the dog has no icon (because someone else in the family made it and the user hasn't selected their own icon OR because the user made it and never added an icon) then the dog just gets the defaultDogIcon
            dog.dogIcon = LocalDogIcon.getIcon(forDogId: dog.dogId) ?? ClassConstant.DogConstant.defaultDogIcon
            dogArray.append(dog)
        }
        
        self.init(forDogs: dogArray)
    }
    
    /// Stores all the dogs. This is get only to make sure integrite of dogs added is kept
    private(set) var dogs: [Dog] = []
    
    /// Helper function allows us to use the same logic for addDog and addDogs and allows us to only sort at the end. Without this function, addDogs would invoke addDog repeadly and sortDogs() with each call.
    func addDogWithoutSorting(forDog newDog: Dog) {
        // If we discover a newDog has the same dogId as an existing dog, we remove
        dogs.removeAll { oldDog in
            guard oldDog.dogId == newDog.dogId else {
                return false
            }
            // we should combine the currentDog's reminders/logs into the new dog
            newDog.combine(withOldDog: oldDog)
            newDog.dogIcon = oldDog.dogIcon
            
            return true
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
        guard let matchingDogIndex = dogs.firstIndex(where: { dog in
            return dog.dogId == dogId
        }) else {
            return
        }
        
        // make sure we invalidate all the timers associated. this isn't technically necessary but its easier to tie up lose ends here
        if let dog = findDog(forDogId: dogId) {
            for reminder in dog.dogReminders.reminders {
                reminder.timer?.invalidate()
            }
        }
        
        dogs.remove(at: matchingDogIndex)
    }
    
    /// Removes a dog at the given index
    func removeDog(forIndex index: Int) {
        // Make sure the index is valid
        guard dogs.count > index else {
            return
        }
        
        // make sure we invalidate all the timers associated. this isn't technically necessary but its easier to tie up lose ends here
        for reminder in dogs[index].dogReminders.reminders {
            reminder.timer?.invalidate()
        }
        
        dogs.remove(at: index)
    }
    
}

extension DogManager {
    
    // MARK: Locate
    
    /// Returns reference of a dog with the given dogId
    func findDog(forDogId dogId: Int) -> Dog? {
        for dog in dogs where dog.dogId == dogId {
            return dog
        }
        
        return nil
    }
    
    /// Returns the index of a dog with the given dogId
    func findIndex(forDogId dogId: Int) -> Int? {
        for d in 0..<dogs.count where dogs[d].dogId == dogId {
            return d
        }
        
        return nil
    }
    
    // MARK: Information
    
    /// Returns true if ANY the dogs present has at least 1 CREATED reminder
    var hasCreatedReminder: Bool {
        for dog in dogs where dog.dogReminders.reminders.count > 0 {
            return true
        }
        return false
    }
    
    /// Returns true if dogs.count > 0
    var hasCreatedDog: Bool {
        if dogs.count > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if ANY the dogs present has at least 1 ENABLED reminder
    var hasEnabledReminder: Bool {
        for dog in dogs {
            for reminder in dog.dogReminders.reminders where reminder.reminderIsEnabled == true {
                return true
            }
        }
        return false
    }
    
    /// Returns number of reminders that are enabled and therefore have a timer.
    var enabledTimersCount: Int {
        var count = 0
        for dog in MainTabBarViewController.staticDogManager.dogs {
            
            for reminder in dog.dogReminders.reminders {
                guard reminder.reminderIsEnabled == true else {
                    continue
                }
                
                count += 1
            }
        }
        return count
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
        
        /*
         let groupedLogsByUniqueDateSorted = Date()
         
         let dogIdLogsTuplesCompiledMSElapsed = (startDate.distance(to: dogIdLogsTuplesCompiled) * 1000)
         let dogIdLogsTuplesSortedMSElapsed = dogIdLogsTuplesCompiled.distance(to: dogIdLogsTuplesSorted) * 1000
         let groupedLogsByUniqueDateCompiledMSElapsed = dogIdLogsTuplesSorted.distance(to: groupedLogsByUniqueDateCompiled) * 1000
         let groupedLogsByUniqueDateSortedMSElapsed = groupedLogsByUniqueDateCompiled.distance(to: groupedLogsByUniqueDateSorted) * 1000
         let totalMSElapsed = startDate.distance(to: groupedLogsByUniqueDateSorted) * 1000
         
         var debugString = "\ngroupedLogsByUniqueDate with \(dogIdLogsTuples.count) dogIdLogsTuples \n"
         debugString.append("\(dogIdLogsTuplesCompiledMSElapsed)\n")
         debugString.append("\(dogIdLogsTuplesSortedMSElapsed)\n")
         debugString.append("\(groupedLogsByUniqueDateCompiledMSElapsed)\n")
         debugString.append("\(groupedLogsByUniqueDateSortedMSElapsed) \n")
         debugString.append("\(totalMSElapsed)\n")
         */
        
        return groupedLogsByUniqueDate
    }
    
    // MARK: Compare
    
    /// Combines all of the dogs, reminders, and logs in union fashion to the dogManager. If a dog, reminder, or log exists in either of the dogManagers, then they will be present after this function is done. Dogs, reminders, or logs in the newDogManager (this object) overwrite dogs, reminders, or logs in the oldDogManager. Note: if one dog is to overwrite another dog, it will first combine the reminder/logs, again the reminders/logs of the newDog will take precident over the reminders/logs of the oldDog.
    func combine(withOldDogManager oldDogManager: DogManager) {
        // the addDogs function overwrites the dog info (e.g. dogName) but combines the reminders / logs in the event that the oldDogManager and the newDogManager both contain a dog with the same dogId. Therefore, we must add the dogs to the oldDogManager (allowing the newDogManager to overwrite the oldDogManager dogs if there is an overlap)
        oldDogManager.addDogs(forDogs: self.dogs)
        // now that the oldDogManager contains its original dogs, our new dogs, and has had its old dogs overwritten (in the case old & new both had a dog with same dogId), we have an updated array.
        dogs = oldDogManager.dogs
        sortDogs()
    }
    
}

protocol DogManagerControlFlowProtocol {
    
    /// Sets DogManger equal to forDogManager, depending on sender will also call methods to propogate change.
    func setDogManager(sender: Sender, forDogManager: DogManager)
    
}
