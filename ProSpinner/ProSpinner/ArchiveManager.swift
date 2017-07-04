//
//  ArchiveManager.swift
//  ProSpinner
//
//  Created by AlexP on 30.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import SpriteKit

enum UserDefaultKeys: String
{
    case red                        = "redCounter"
    case blue                       = "blueCounter"
    case green                      = "greenCounter"
    case mainSpinnerIndex           = "mainSpinnerIndex"
    case interstitialCount          = "interstitalCount"
    case spinnersInDisk             = "Spinners"
    case firstTimeRun               = "firstTimeRun"
    case highScore                  = "highScore"
}

class ArchiveManager
{
    static var spinnersArrayInDisk : [Spinner] = [Spinner]()
    {
        didSet
        {
            ArchiveManager.write_SpinnerToUserDefault(spinners: spinnersArrayInDisk)
        }
    }
    
    static var currentlyAtIndex  = ArchiveManager.mainSpinnerLocation
    
    static var mainSpinnerLocation : Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.mainSpinnerIndex.rawValue)
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.mainSpinnerIndex.rawValue)
            UserDefaults.standard.synchronize()
                
        }
    }
    
    static var interstitalCount : Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.interstitialCount.rawValue)
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.interstitialCount.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var currentSpinner : Spinner
    {
        get
        {
            return ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex]
        }
    }
    
    static func write_SpinnerToUserDefault(spinners : [Spinner])
    {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: spinners)
        
        UserDefaults.standard.set(encodedData, forKey: UserDefaultKeys.spinnersInDisk.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func currentSpinnerHasBeenUnlocked()
    {
        resetMainSpinners()
        ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].unlocked = true
        ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].mainSpinner = true
        mainSpinnerLocation = ArchiveManager.currentlyAtIndex
        let updatedArray = ArchiveManager.spinnersArrayInDisk
        write_SpinnerToUserDefault(spinners: updatedArray)
    }
    
    static func resetMainSpinners()
    {
        for spinner in spinnersArrayInDisk { spinner.mainSpinner = false }
    }
    
    static func read_SpinnersFromUserDefault() -> [Spinner]
    {
        if let data = UserDefaults.standard.data(forKey: UserDefaultKeys.spinnersInDisk.rawValue)
        {
            if let spinnerArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Spinner]
            {
                ArchiveManager.spinnersArrayInDisk = spinnerArray
                return spinnerArray
            }
        }
        else
        {
            print("There is an issue")
        }
        return [Spinner]()
    }
    
    static var highScoreRecord : Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.highScore.rawValue)
        }
        set
        {
            if newValue > highScoreRecord
            {
                UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.highScore.rawValue)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    static var firstTimeRun : Bool
    {
        get
        {
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.firstTimeRun.rawValue)
        }
        set
        {
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.firstTimeRun.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
