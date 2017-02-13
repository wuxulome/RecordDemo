//
//  RDCoreDataManager.swift
//  RecordDemo
//
//  Created by wuxu on 2017/2/7.
//  Copyright © 2017年 wuxu. All rights reserved.
//

import UIKit
import CoreData

class RDCoreDataManager: NSObject {
    
    static func save(voice: RDVoiceModel) -> Bool {
        if let result = self.save(voices:[voice])?.first{
            return result
        }
        
        return false
    }
    
    static func save(voices: [RDVoiceModel]) -> [Bool]? {
        
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "RDVoice", in:context)
        
        if let entity = entity {
            let results = voices.map({ (voice) -> Bool in
                //创建voice对象，利用kvc设值
                let tempVoice = NSManagedObject(entity: entity, insertInto:context)
                tempVoice.setValue(voice.id, forKey: "id")
                tempVoice.setValue(voice.name, forKey: "name")
                tempVoice.setValue(voice.duration, forKey: "duration")
                tempVoice.setValue(voice.ctime, forKey: "ctime")
                tempVoice.setValue(voice.size, forKey: "size")
                
                //保存
                do {
                    try context.save()
                    RDLogManager.log("保存成功！")
                    return true
                } catch {
                    RDLogManager.log("保存失败：\(error)")
                    return false
                }
            })
            
            return results
        }
        
        RDLogManager.log("entity创建失败")
        return nil
    }
    
    static func getVoices() -> [RDVoiceModel]? {
        
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>.init(entityName: "RDVoice")
        
        do {
            let results = try context.fetch(request)
            
            return results.map({ (result) -> RDVoiceModel in
                let voice = RDVoiceModel()
                if let id = result.value(forKey: "id") as? Int32 {
                    voice.id = id
                }
                
                if let name = result.value(forKey: "name") as? String {
                    voice.name = name
                }
                
                if let duration = result.value(forKey: "duration") as? TimeInterval {
                    voice.duration = duration
                }
                
                if let ctime = result.value(forKey: "ctime") as? Date {
                    voice.ctime = ctime
                }
                
                if let size = result.value(forKey: "size") as? Int64 {
                    voice.size = size
                }
                
                return voice
            })
        } catch  {
            RDLogManager.log("获取失败：\(error)")
            return nil
        }
    }
}
