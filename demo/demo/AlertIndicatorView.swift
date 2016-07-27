//
//  AlertIndicatorView.swift
//  demo
//
//  Created by qing on 16/7/22.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit

class AlertIndicatorView: UIView {
    
    private var aiv: UIActivityIndicatorView!
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.backgroundColor = UIColor.whiteColor()
        self.addSubview(bgView)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bgView]|", options: .DirectionLeftToRight, metrics: nil, views: ["bgView": bgView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bgView(>=70)]|", options: .DirectionLeftToRight, metrics: nil, views: ["bgView": bgView]))
        
        aiv = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = UIColor(red: 0, green: 190 / 255, blue: 192 / 255, alpha: 1)
        bgView.addSubview(aiv)
        
        bgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[aiv]", options: .DirectionLeftToRight, metrics: nil, views: ["aiv": aiv]))
        bgView.addConstraint(NSLayoutConstraint(item: aiv, attribute: .CenterY, relatedBy: .Equal, toItem: bgView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.grayColor()
        titleLabel.font = UIFont.systemFontOfSize(16)
        titleLabel.text = "正在识别中，请耐心等待"
        bgView.addSubview(titleLabel)
        
        bgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[aiv]-20-[titleLabel]-20-|", options: .AlignAllCenterY, metrics: nil, views: ["titleLabel": titleLabel, "aiv": aiv]))
        
    
    }
    
    func startAnimating() {
        aiv.startAnimating()
    }
    
    func stopAnimating() {
        if aiv.isAnimating() {
            aiv.stopAnimating()
        }
    }
}
