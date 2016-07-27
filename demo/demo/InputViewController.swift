//
//  InputViewController.swift
//  demo
//
//  Created by qing on 16/7/19.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {

    // 姓名
    @IBOutlet weak var nameField: UITextField!
    // 身份证
    @IBOutlet weak var idcardField: UITextField!
    // 下一步
    @IBOutlet weak var nextButton: UIButton!

    private var name: String = ""
    private var idcard: String = ""
    
    var base64Img: String = ""
    
    init() {
        super.init(nibName: "InputViewController", bundle: nil)
    }
    
    init(name: String, idcard: String) {
        super.init(nibName: "InputViewController", bundle: nil)

        self.name = name
        self.idcard = idcard
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "确认身份证信息"
        
        let item = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        nextButton.layer.masksToBounds = true
        nextButton.layer.cornerRadius = 4
        nextButton.backgroundColor = UIColor(red: 0, green: 198 / 255, blue: 190 / 255, alpha: 1)
        
        self.nameField.text = name
        self.idcardField.text = idcard
    }

    @IBAction func buttonPressed(sender: UIButton) {
        if self.nameField.isFirstResponder() {
            self.nameField.resignFirstResponder()
        }
        if self.idcardField.isFirstResponder() {
            self.idcardField.resignFirstResponder()
        }
        
        let controller = DetectFaceViewController(name: self.nameField.text!, idcard: self.idcardField.text!)
        controller.base64Img = self.base64Img
        self.navigationController?.pushViewController(controller, animated: true)
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
