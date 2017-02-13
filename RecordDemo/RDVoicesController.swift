//
//  RDVoicesTableViewController.swift
//  RecordDemo
//
//  Created by wuxu on 2017/2/8.
//  Copyright © 2017年 wuxu. All rights reserved.
//

import UIKit
import AVFoundation

class RDVoicesController: UITableViewController {
    
    var voices = [RDVoiceModel]()
    var playCellIndex: IndexPath?
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 135
        self.tableView.rowHeight = UITableViewAutomaticDimension

        if let result = RDCoreDataManager.getVoices() {
            voices = result
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard voices.count > indexPath.row else {
            RDLogManager.log("cell count > source count")
            let cell = UITableViewCell.init()
            cell.contentView.superview?.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard voices.count > indexPath.row else {
            RDLogManager.log("cell count > source count")
            return
        }
        
        guard let cell = cell as? RDVoiceCell else {
            RDLogManager.log("播放row大于数据源总量")
            return
        }
        
        let voice = voices[indexPath.row]
        cell.update(with: voice)
        cell.playButtonClick = { [weak self] (cell: RDVoiceCell, model: RDVoiceModel) -> () in
            self?.playCellIndex = self?.tableView.indexPath(for: cell)
            self?.playVoice(cell: cell, model: model)
        }
        
        if indexPath == playCellIndex {
            if let isPlaying = player?.isPlaying, isPlaying {
                cell.setButtonPlayState()
            } else {
                cell.setButtonPauseState()
            }
        } else {
            cell.setButtonPauseState()
        }
    }
}

extension RDVoicesController: AVAudioPlayerDelegate {
    
    func playVoice(cell: RDVoiceCell, model: RDVoiceModel) {
        
        //同一段音频，执行播放或暂停。不同则清除播放状态
        if let player = player {
            if player.url == model.voiceURL {
                if player.isPlaying {
                    player.pause()
                    cell.setButtonPauseState()
                } else {
                    player.play()
                    cell.setButtonPlayState()
                }
                return
            } else {
                self.cleanPlayState()
            }
        }
        
        //如果不存在player，则初始化
        do {
            player = try AVAudioPlayer.init(contentsOf: model.voiceURL)
            player?.delegate = self
            if let success = player?.play(), success {
                cell.setButtonPlayState()
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
    }
    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let playCellIndex = playCellIndex,
            let cell = tableView.cellForRow(at: playCellIndex) as? RDVoiceCell {
            cell.setButtonPauseState()
            self.playCellIndex = nil
        }
    }
}
