//
//  ViewController.swift
//  RecordDemo
//
//  Created by wuxu on 2017/2/7.
//  Copyright © 2017年 wuxu. All rights reserved.
//

import UIKit
import AVFoundation

class RDRecordController: UIViewController {
    
    // MARK: Property
    
    var voice: RDVoiceModel?
    var lastSuccessVoice: RDVoiceModel?
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    lazy var recordSetting = [AVSampleRateKey: NSNumber.init(value: 8000.0),
                              AVFormatIDKey:NSNumber.init(value: kAudioFormatAppleIMA4),
                              AVLinearPCMBitDepthKey:NSNumber.init(value: 16),//采样位数
                              AVNumberOfChannelsKey:NSNumber.init(value: 1),// 音频通道数
                              AVEncoderAudioQualityKey:NSNumber.init(value: AVAudioQuality.high.rawValue)]
    
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ctimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: button action
    
    //录音按钮
    @IBAction func record(_ sender: UILongPressGestureRecognizer) {
        //清除播放状态
        self.cleanPlayState()
        
        switch sender.state {
        case .began:
            //开始新一轮录音
            voice = RDVoiceModel()
            if let voice = voice {
                voice.ctime = Date.init()
                voice.id = RDTool.getNextIDAndSave()
                voice.name = "voice_\(voice.id)"+".caf"
                
                self.beganRecord()
            }
            
            break
            
        case .ended:
            //结束新一轮录音
            self.endRecord()
            
            //保存录音
            if let voice = voice,
                let ctime = voice.ctime {
                voice.duration = Date.init().timeIntervalSince(ctime)
                
                do {
                    let vdata = try Data.init(contentsOf: voice.voiceURL)
                    voice.size = Int64(vdata.count)/1024
                } catch  {
                    RDLogManager.log("录音文件获取错误 \(error)")
                    voice.size = 0
                }
                
                _ = RDCoreDataManager.save(voice:voice)
            }
            
            //为播放功能，进行转存
            lastSuccessVoice = voice
            voice = nil
            
            //显示playButton
            playButton.isHidden = false
            
            //设置新的音频信息
            if let lastSuccessVoice = lastSuccessVoice {
                idLabel.text = "ID：" + String(describing: lastSuccessVoice.id)
                nameLabel.text = "文件名：" + lastSuccessVoice.name
                if let ctime = lastSuccessVoice.ctime {
                    ctimeLabel.text = "创建时间：" + RDTool.format(date: ctime)
                }
                durationLabel.text = "持续时长：" + String(format: "%.2f", lastSuccessVoice.duration) + "s"
                sizeLabel.text = "大小：" + String(describing: lastSuccessVoice.size) + "KB"
            }
            
            break
            
        case .cancelled:
            self.cancelRecord()
            voice = nil
            break
            
        case .failed:
            self.cancelRecord()
            voice = nil
            break
            
        default:
            break
        }
    }
    
    //播放按钮
    @IBAction func play(_ sender: UIButton) {
        self.playVoice()
    }
}

extension RDRecordController {
    //开始录音
    func beganRecord() {
        //检查录音存储model
        guard let voice = voice else {
            RDLogManager.log("录音存储model为空")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            RDLogManager.log("AVAudioSession设置错误 \(error)")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            RDLogManager.log("AVAudioSession设置错误 \(error)")
            return
        }
        
        do {
            recorder = try AVAudioRecorder.init(url: voice.voiceURL, settings: recordSetting)
            recorder?.prepareToRecord()
            
            RDLogManager.log("开始录音...")
            recorder?.record()
        } catch {
            RDLogManager.log("初始化AVAudioRecorder失败")
            return
        }
    }
    
    //结束录音
    func endRecord() {
        guard let isRecording = recorder?.isRecording, isRecording else {
            RDLogManager.log("结束录音失败，录音未启动")
            return
        }
        
        recorder?.stop()
        RDLogManager.log("结束录音...")
    }
    
    //取消录音
    func cancelRecord() {
        //检查录音存储model
        guard let voice = voice else {
            RDLogManager.log("录音存储model为空")
            return
        }
        
        //检查录音状态
        guard let isRecording = recorder?.isRecording, isRecording else {
            RDLogManager.log("取消录音失败，录音未启动")
            return
        }
        
        recorder?.stop()
        
        _ = RDVoiceModel.clean(voice: voice)
        
        RDLogManager.log("取消录音...")
    }
}

extension RDRecordController: AVAudioPlayerDelegate {
    
    //播放上一段录制的音频
    func playVoice() {
        //检查录音存储model
        guard let lastSuccessVoice = lastSuccessVoice else {
            RDLogManager.log("音频model为空")
            return
        }
        
        //如果存在player，则执行播放或暂停操作
        if let player = player {
            if player.isPlaying {
                player.pause()
                playButton.setTitle("播放", for: .normal)
                playButton.setTitle("播放", for: .highlighted)
            } else {
                player.play()
                playButton.setTitle("暂停", for: .normal)
                playButton.setTitle("暂停", for: .highlighted)
            }
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            RDLogManager.log("AVAudioSession设置错误 \(error)")
            return
        }
        
        //如果不存在player，则初始化
        do {
            player = try AVAudioPlayer.init(contentsOf: lastSuccessVoice.voiceURL)
            player?.delegate = self
            if let success = player?.play(), success {
                playButton.setTitle("暂停", for: .normal)
                playButton.setTitle("暂停", for: .highlighted)
            } else {
               RDLogManager.log("play failed")
            }
        } catch {
            RDLogManager.log("AVAudioPlayer创建错误 \(error)")
            return
        }
    }
    
    //清除播放状态
    func cleanPlayState() {
        player?.stop()
        player = nil
        
        playButton.setTitle("播放", for: .normal)
        playButton.setTitle("播放", for: .highlighted)
    }
    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("播放", for: .normal)
        playButton.setTitle("播放", for: .highlighted)
    }
}

