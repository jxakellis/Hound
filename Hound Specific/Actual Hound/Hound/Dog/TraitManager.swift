//
//  TraitManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from DogSpecificationManager
enum TraitManagerError: Error{
    case nilName
    case blankName
    case invalidName
    case logUUIDPresent
    case logUUIDNotPresent
}

protocol TraitManagerProtocol{
    
    ///Icon for dog, default paw but can be picture from camera roll
    var icon: UIImage { get set }
    
    ///Resets to default
    mutating func resetIcon()
    
    ///logs that aren't attached to a reminder object, free standing with no timing involved
    var logs: [KnownLog] { get }
    
    ///adds a log to logs, used for source control so all logs are handled through this path
    mutating func addLog(newLog: KnownLog) throws
    
    ///updates a log in logs, used for source control so all logs are handled through this path
    mutating func changeLog(forUUID uuid: String, newLog: KnownLog) throws
    
    ///removes a log in logs, used for source control so all logs are handled through this path
    mutating func removeLog(forUUID uuid: String) throws
    
    mutating func removeLog(forIndex index: Int)
    
    ///The dog's name
    var dogName: String { get }
    ///Changes the dog's name
    mutating func changeDogName(newDogName: String?) throws
    
    ///The dog's description
    //var dogDescription: String { get }
    ///Changes the dog's description
    //mutating func changeDogDescription(newDogDescription: String) throws
}

class TraitManager: NSObject, NSCoding, NSCopying, TraitManagerProtocol {
    
    
    //MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TraitManager()
        copy.icon = self.icon
        copy.storedDogName = self.storedDogName
        copy.storedLogs = self.storedLogs
        return copy
    }
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        icon = aDecoder.decodeObject(forKey: "icon") as! UIImage
        storedDogName = aDecoder.decodeObject(forKey: "dogName") as! String
        storedLogs = aDecoder.decodeObject(forKey: "logs") as! [KnownLog]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDogName, forKey: "dogName")
        aCoder.encode(storedLogs, forKey: "logs")
        aCoder.encode(icon, forKey: "icon")
    }
    
    //static var supportsSecureCoding: Bool = true
    
    override init() {
        super.init()
    }
    
    var icon: UIImage = UIImage.init(named: "pawFullResolutionWhite")!
    
    func resetIcon(){
        icon = UIImage.init(named: "pawFullResolutionWhite")!
    }
    
    private var storedLogs: [KnownLog] = []
    var logs: [KnownLog] { return storedLogs }
    
    func addLog(newLog: KnownLog) throws {
        for log in logs{
            //makes sure log uuid isn't repeat
            if log.uuid == newLog.uuid{
                throw TraitManagerError.logUUIDPresent
            }
        }
        storedLogs.append(newLog)
        print("ENDPOINT Add Log")
    }
    
    func changeLog(forUUID uuid: String, newLog: KnownLog) throws {
        //check to find the index of targetted log
        var newLogIndex: Int?
        
        for i in 0..<logs.count {
            if logs[i].uuid == uuid {
                newLogIndex = i
                break
            }
        }
        
        if newLogIndex == nil {
            throw TraitManagerError.logUUIDNotPresent
        }
        
        else {
            storedLogs[newLogIndex!] = newLog
            print("ENDPOINT Update Log")
        }
    }
    
    func removeLog(forUUID uuid: String) throws {
        //check to find the index of targetted log
        var logIndex: Int?
        
        for i in 0..<logs.count {
            if logs[i].uuid == uuid {
                logIndex = i
                break
            }
        }
        
        if logIndex == nil {
            throw TraitManagerError.logUUIDNotPresent
        }
        
        else {
            storedLogs.remove(at: logIndex ?? -1)
            print("ENDPOINT Remove Log (uuid)")
        }
    }
    
    func removeLog(forIndex index: Int){
        storedLogs.remove(at: index)
        print("ENDPOINT Remove Log (index)")
    }
    
    private var storedDogName: String = DogConstant.defaultName
    var dogName: String { return storedDogName }
    func changeDogName(newDogName: String?) throws {
        if newDogName == nil {
            throw TraitManagerError.nilName
        }
        else if newDogName!.trimmingCharacters(in: .whitespaces) == ""{
            throw TraitManagerError.blankName
        }
        else {
            storedDogName = newDogName!
        }
    }
    
    
}
