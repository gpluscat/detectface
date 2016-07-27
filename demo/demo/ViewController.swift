//
//  ViewController.swift
//  demo
//
//  Created by qing on 16/7/18.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    private var contentView: UIScrollView!
    private var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.edgesForExtendedLayout = .None
        
        let item = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        contentView = UIScrollView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.pagingEnabled =  true
        contentView.bounces = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.delegate = self
        self.view.addSubview(contentView)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: .DirectionLeftToRight, metrics: nil, views: ["contentView": contentView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: .DirectionLeftToRight, metrics: nil, views: ["contentView": contentView]))
        
        initViews()
        
    }
    
    /// 初始化视图
    private func initViews() {
        var x: CGFloat = 0
        for i in 0 ..< 3 {
            let image = UIImage(named: "loading\(i + 1)")
            
            let iv = UIImageView(frame: CGRectMake(x, 0, self.view.frame.size.width, self.view.frame.size.height))
            iv.image = image
            contentView.addSubview(iv)
            
            x += self.view.frame.size.width
            
            if i == 2 {
                iv.userInteractionEnabled = true
                
                // 添加button
                let startButton = UIButton(type: .System)
                startButton.translatesAutoresizingMaskIntoConstraints = false
                startButton.setTitle("开始体验", forState: .Normal)
                startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                startButton.addTarget(self, action: #selector(doStart), forControlEvents: .TouchUpInside)
                startButton.layer.masksToBounds = true
                startButton.layer.cornerRadius = 4
                startButton.backgroundColor = UIColor(red: 0, green: 141.0 / 255, blue: 211.0 / 255, alpha: 1)
                iv.addSubview(startButton)
                
                iv.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[startButton(40)]-60-|", options: .DirectionLeftToRight, metrics: nil, views: ["startButton": startButton]))
                iv.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[startButton(>=120)]", options: .DirectionLeftToRight, metrics: nil, views: ["startButton": startButton]))
                iv.addConstraint(NSLayoutConstraint(item: startButton, attribute: .CenterX, relatedBy: .Equal, toItem: iv, attribute: .CenterX, multiplier: 1, constant: 0))
            }
        }
        
        contentView.contentSize = CGSizeMake(x, self.view.frame.size.height)
        
        // page control 
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor.greenColor()
        pageControl.pageIndicatorTintColor = UIColor.grayColor()
        self.view.addSubview(pageControl)
        
        self.view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: -10))
        
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
    }
    
    func doStart() {
        let controller = IdcardViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let index = Int(scrollView.contentOffset.x / pageWidth)
        pageControl.currentPage = index
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }

}

