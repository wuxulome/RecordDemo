//
//  RDLogManager.swift
//  RecordDemo
//
//  Created by wuxu on 2017/2/10.
//  Copyright © 2017年 wuxu. All rights reserved.
//

import UIKit

class RDLogManager: NSObject {
    static func log(_ msg: String) {
        #if DEBUG
            print(msg)
        #else
            RDLogManager.uploadLog(msg)
        #endif
    }
    
    private static func uploadLog(msg: String) {
        //上传日志到服务器
    }
}
