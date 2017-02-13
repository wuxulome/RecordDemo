//
//  RDVoiceModel.swift
//  RecordDemo
//
//  Created by wuxu on 2017/2/7.
//  Copyright © 2017年 wuxu. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class RDVoiceModel: NSObject {
    
    var id: Int32 = 0
    var name: String = ""
    var ctime: Date?
    var duration: TimeInterval = 0
    var size: Int64 = 0
    var voiceURL: URL {
        get {
            return URL.init(fileURLWithPath: kPath! + "/" + name)
        }
    }
    
    static func clean(voice: RDVoiceModel) -> NSError? {
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: voice.voiceURL.description)
        
        if exist {
            do {
                try fileManager.removeItem(at: voice.voiceURL)
                return nil
            } catch  {
                return error as NSError?
            }
        } else {
            return NSError.init(domain: "rd.com", code: 101, userInfo: nil)
        }
    }
}
