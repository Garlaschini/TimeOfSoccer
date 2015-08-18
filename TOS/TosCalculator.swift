//
//  TosCalculator.swift
//  TOS
//
//  Created by Matteo Vitolo on 30/07/15.
//  Copyright (c) 2015 Funambol. All rights reserved.
//

import Foundation

public class TOSCalculator {

    internal var team = NSMutableDictionary()
    internal var players = NSArray()
    
    class var sharedInstance: TOSCalculator {
        struct Static {
            static let instance: TOSCalculator = TOSCalculator()
        }
        return Static.instance
    }
    
    init() {
        
        let jsonDict = getJsonData("players")
        let jsonContainer = jsonDict.objectForKey("Players") as! NSDictionary
        players = jsonContainer.objectForKey("Player") as! NSArray
        resetTeam()
    }
    
    func resetTeam(){
        for index in 1...11{
            var playerArray = NSDictionary()
            team[index] = playerArray
        }
    }
    
    private func getJsonData(FileName:String) ->NSDictionary{
        var error: NSError?
        let path = NSBundle.mainBundle().pathForResource(FileName, ofType: "json")
        let pathURL = NSURL(string: path!)
        var data: NSData? = NSData(contentsOfFile: path!)
        let jsonDict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as! NSDictionary
        return jsonDict
    }
    
    func addPlayerToTeam(shirtnumber: Int, position:Int) ->Bool {
        for player in players {
            if (player as! NSDictionary).objectForKey("ShirtNumber") as! Int == shirtnumber {
                let playerPositions = (player.objectForKey("Positions") as! NSArray)
                
                for playerPosition in playerPositions {
                    if ((playerPosition.objectForKey("Position") as! Int) == position){
                        team[position] = player
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func getModifierForPosition(positionIndex: Int) ->NSString{
        switch positionIndex{
        case 1:
            return "OrangeDown"
        case 2:
            return "OrangeLeft"
        case 3:
            return "OrangeDown"
        case 4:
            return "OrangeDown"
        case 5:
            return "OrangeRight"
        case 6:
            return "BlueLeft"
        case 7:
            return "YellowTop"
        case 8:
            return "YellowTop"
        case 9:
            return "BlueRight"
        case 10:
            return "RedTop"
        case 11:
            return "RedTop"
        default:
            return ""
        }
    }
    
    func getLeftConnection(positionIndex: Int) -> Int{
        var res = 0
        let player = team.objectForKey(positionIndex) as! NSDictionary
        if ( player.count == 0 || positionIndex == 2 || positionIndex == 6){
            return res
        }
        var nextPosition = positionIndex - 1
        var modifier = 0
        var addExtraConnection = false
        if (positionIndex == 9){
            addExtraConnection = true
        }else if (positionIndex == 10){
            modifier = 2
        }
        var nextplayer = team.objectForKey(positionIndex) as! NSDictionary
        if ( nextplayer.count > 0){
            let connString = player.objectForKey("LeftCon") as! NSString
            if ( connString.isEqualToString("")){
                return 0
            }
            let otherString = nextplayer.objectForKey("RightCon") as! NSString
            if (connString.isEqualToString(otherString as String)){
                if (!connString.isEqualToString("B")){
                    modifier = 0
                }
                res = 1 + modifier
            }
        }
        if (addExtraConnection) {
            nextplayer = team.objectForKey(11) as! NSDictionary
            if ( nextplayer.count > 0){
                let connString = player.objectForKey("LeftCon") as! NSString
                let otherString = nextplayer.objectForKey("RightCon") as! NSString
                if (connString.isEqualToString(otherString as String) && connString.isEqualToString("B")){
                    res += 3
                }
            }
        }
        return res
    }
    
    func getRightConnection(positionIndex: Int) -> Int{
        
        var res = 0
        let player = team.objectForKey(positionIndex) as! NSDictionary
        if ( player.count == 0 || positionIndex == 5 || positionIndex == 9){
            return res
        }
        var nextPosition = positionIndex + 1
        var modifier = 0
        var addExtraConnection = false
        if (positionIndex == 6){
            addExtraConnection = true
        }else if (positionIndex == 11){
            modifier = 2
        }
        var nextplayer = team.objectForKey(positionIndex) as! NSDictionary
        if ( nextplayer.count > 0){
            let connString = player.objectForKey("RightCon") as! NSString
            if ( connString.isEqualToString("")){
                return 0
            }
            let otherString = nextplayer.objectForKey("LeftCon") as! NSString
            if (connString.isEqualToString(otherString as String)){
                if (!connString.isEqualToString("B")){
                    modifier = 0
                }

                res = 1 + modifier
            }
        }
        if (addExtraConnection) {
            nextplayer = team.objectForKey(10) as! NSDictionary
            if ( nextplayer.count > 0){
                let connString = player.objectForKey("RightCon") as! NSString
                let otherString = nextplayer.objectForKey("LeftCon") as! NSString
                if (connString.isEqualToString(otherString as String) && connString.isEqualToString("B")){
                    res += 3
                }
            }
        }
        return res
    }
    
    func getDownConnection(positionIndex: Int) -> Int{
        var res = 0
        let player = team.objectForKey(positionIndex) as! NSDictionary
        if ( player.count == 0 || positionIndex < 6){
            return res
        }
        var nextPosition = 0
        var modifier = 2
        
        if ( positionIndex < 10 ){
            nextPosition = positionIndex - 4
        } else {
            nextPosition = positionIndex - 3
        }
        
        if ( positionIndex == 7 || positionIndex == 8 ){
            modifier = 0
        }
        
        var nextplayer = team.objectForKey(positionIndex) as! NSDictionary
        if ( nextplayer.count > 0){
            let connString = player.objectForKey("DownCon") as! NSString
            if ( connString.isEqualToString("")){
                return 0
            }
            let otherString = nextplayer.objectForKey("TopCon") as! NSString
            if (connString.isEqualToString(otherString as String)){
                if (!connString.isEqualToString("Y")){
                    modifier = 0
                }
                res = 1 + modifier
            }
        }
        return res
    }
    
    
    func getTopConnection(positionIndex: Int) -> Int{
        var res = 0
        let player = team.objectForKey(positionIndex) as! NSDictionary
        if ( player.count == 0 || positionIndex > 10 || positionIndex == 6 || positionIndex == 9){
            return res
        }
        var nextPosition = 0
        var modifier = 2
        
        if ( positionIndex < 6 ){
            nextPosition = positionIndex + 4
        } else {
            nextPosition = positionIndex + 3
        }
        
        if ( positionIndex == 3 || positionIndex == 4 ){
            modifier = 0
        }
        
        var nextplayer = team.objectForKey(positionIndex) as! NSDictionary
        if ( nextplayer.count > 0){
            let connString = player.objectForKey("TopCon") as! NSString
            if ( connString.isEqualToString("")){
                return 0
            }
            let otherString = nextplayer.objectForKey("DownCon") as! NSString
            if (connString.isEqualToString(otherString as String)){
                if (!connString.isEqualToString("Y")){
                    modifier = 0
                }
                res = 1 + modifier
            }
        }
        return res
    }
    
    func getConnectionMultiplier(positionIndex: Int) ->Int{
        if (positionIndex == 1){
            return 0
        }
        var res = 0
        res += getLeftConnection(positionIndex)
        res += getRightConnection(positionIndex)
        res += getTopConnection(positionIndex)
        res += getDownConnection(positionIndex)
        
        return res
    }
    
    func calculatePlayer(playerPosition: Int) ->Int{
        var result = 0
        let teamplayer = team.objectForKey(playerPosition) as! NSDictionary
        
        if(teamplayer.count == 0) {
            return -3
        }
        let res = teamplayer.objectForKey(getModifierForPosition(playerPosition)) as! Int
        result += res
        
        let conn = getConnectionMultiplier(playerPosition)
        result += conn
        return result
    }
    
    func calculateAttack() -> Int{
        var result = 0
        
        for index in 6...11{
            result += calculatePlayer(index)
        }
        
        return result
    }
    
    func calculateDefense() -> Int{
        
        var result = 0
        
        for index in 1...5{
            result += calculatePlayer(index)
        }
        
        return result
    }
    

}