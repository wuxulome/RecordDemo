//
//  RDVoiceCell.swift
//  RecordDemo
//
//  Created by wuxu on 2017/2/9.
//  Copyright © 2017年 wuxu. All rights reserved.
//

import UIKit

class RDVoiceCell: UITableViewCell {
    
    // MARK: Property
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ctimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var playButtonClick: ((RDVoiceCell, RDVoiceModel) -> ())?
    var voiceModel: RDVoiceModel?
    
    // MARK: life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with voiceModel: RDVoiceModel) {
        self.voiceModel = voiceModel
        
        idLabel.text = "ID：" + String(describing: voiceModel.id)
        nameLabel.text = "文件名：" + voiceModel.name
        if let ctime = voiceModel.ctime {
            ctimeLabel.text = "创建时间：" + RDTool.format(date: ctime)
        }
        durationLabel.text = "持续时长：" + String(format: "%.2f", voiceModel.duration) + "s"
        sizeLabel.text = "大小：" + String(describing: voiceModel.size) + "KB"
    }

    // MARK: button event
    
    @IBAction func playButtonClick(_ sender: UIButton) {
        guard let playButtonClick = playButtonClick else {
            return
        }
        
        if let voiceModel = voiceModel {
            playButtonClick(self, voiceModel)
        }
    }
}

extension RDVoiceCell {
    
    func setButtonPauseState() {
        self.playButton.setTitle("播放", for: .normal)
        self.playButton.setTitle("播放", for: .highlighted)
        self.backgroundColor = UIColor.white
    }
    
    func setButtonPlayState() {
        self.playButton.setTitle("暂停", for: .normal)
        self.playButton.setTitle("暂停", for: .highlighted)
        self.backgroundColor = UIColor.init(red: 0.7, green: 0, blue: 0, alpha: 0.5)
    }
}
