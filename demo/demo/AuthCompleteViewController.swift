//
//  AuthCompleteViewController.swift
//  demo
//
//  Created by qing on 16/7/21.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit

class AuthCompleteViewController: UIViewController {

    @IBOutlet weak var nameLael: UILabel!
    @IBOutlet weak var voiceLabel: UILabel!
    @IBOutlet weak var faceCompareLabel: UILabel!
    @IBOutlet weak var authTimeLabel: UILabel!
    
    private var name: String = ""
    private var voice: String = ""
    private var similarity: String = ""
    
    init(name: String, voice: String, similarity: String) {
        super.init(nibName: "AuthCompleteViewController", bundle: nil)
        
        self.name = name
        self.voice = voice
        self.similarity = similarity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        
        let nameStr = "认证人：\(self.self.name)"
        let attr = NSMutableAttributedString(string: nameStr)
        attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.greenColor(), range: NSString(string: nameStr).rangeOfString(self.name))
        
        self.nameLael.attributedText = attr
        self.voiceLabel.text = "语音识别：\(self.voice)"
        self.faceCompareLabel.text = "身份证人脸对比：\(self.similarity)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let time = NSDate()
        let timeStr = dateFormatter.stringFromDate(time)
        
        authTimeLabel.text = "认证时间：\(timeStr)"
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
