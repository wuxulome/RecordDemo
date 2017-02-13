//
//  RDTool.swift
//  RecordDemo
//
//  Created by wuxu on 2017/2/9.
//  Copyright © 2017年 wuxu. All rights reserved.
//

import UIKit

private let kVoiceMaxIDKey = "kVoiceMaxIDKey"
private let dateFormatter = DateFormatter()
let kPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last

class RDTool: NSObject {
    
    
}

extension RDTool {
    static func maxID() -> Int32 {
        if let vMaxID = UserDefaults.standard.object(forKey: kVoiceMaxIDKey) as? NSNumber {
            return Int32(vMaxID)
        } else {
            return 0
        }
    }
    
    static func getNextIDAndSave() -> Int32 {
        UserDefaults.standard.set(RDTool.maxID() + 1, forKey: kVoiceMaxIDKey)
        UserDefaults.standard.synchronize()
        return RDTool.maxID() + 1
    }
}

extension RDTool {
    static func format(date: Date) -> String {
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
