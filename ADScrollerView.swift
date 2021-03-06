//
//  ADScrollerView.swift
//  NZImageShowDemo
//
//  Created by NeoZ on 11/6/16.
//  Copyright © 2016 NeoZ. All rights reserved.
//

import UIKit
import Kingfisher

@objc public protocol ADScrollerViewDelegate {
    optional func ADScrollerViewDidclicked(index : Int)
}

let timeInterval = 3.0

let imageKey = "image"
let titleKey = "title"

class ADScrollerView: UIView, UIScrollViewDelegate {

    private var moveTimer : NSTimer? = nil
    
    private var pageRollingWidth = CGFloat()
    
    var customDelegate : ADScrollerViewDelegate?
    
    private let originFrame: CGRect
    
    private var currentDisplyedPage : Int {
        get{
            return pagecontrol.currentPage
        }set{
            pagecontrol.currentPage = newValue
            
            if let titleString = imageArray[currentDisplyedPage][titleKey] where titleString.characters.count > 0 {
                titleLabel.text = titleString
            }else{
                titleLabel.text = "Untitled"
            }
        }
    }

    var imageArray = [[String: String]]() {
        didSet{
            pagecontrol.numberOfPages = imageArray.count
            currentDisplyedPage = 0
            
            attachImageView(self.bounds)
        }
    }
    
    internal func setupTimer() {
        if moveTimer == nil {
            moveTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(ADScrollerView.moveImage), userInfo: nil, repeats: true)
        }
    }
    
    internal func invalidateTimer() {
        if moveTimer!.valid {
            moveTimer!.invalidate()
            moveTimer = nil
        }
    }
    
    
    private var scrollerView: UIScrollView = {
        let view = UIScrollView()
        view.pagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.scrollEnabled = true
        view.clipsToBounds = true
        view.bounces = false
        
        return view
    }()
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15.0)
        label.textColor = UIColor.grayColor()
        //label.backgroundColor = UIColor.whiteColor()
        label.alpha = 0.8
        
        return label
    }()
    
    private var pagecontrol : UIPageControl = {
        let page = UIPageControl()
        page.frame = CGRectMake(0, 0, 200, 30)
        page.currentPage = 0
        page.currentPageIndicatorTintColor = UIColor.whiteColor()
        page.pageIndicatorTintColor = UIColor.lightGrayColor()
        
        return page
    }()
    
    required override init(frame: CGRect) {
        self.originFrame = frame
        pageRollingWidth = frame.size.width
        
        super.init(frame: frame)
        initialFunc(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.originFrame = aDecoder.decodeCGRectForKey("originFrame")
        super.init(coder: aDecoder)

        initialFunc(frame)
    }
    
    private func initialFunc(rect: CGRect) {
        self.autoresizesSubviews = true
        self.clipsToBounds = true
        
        self.addSubview(scrollerView)
        self.addSubview(pagecontrol)
        self.addSubview(titleLabel)
        
        scrollerView.delegate = self
        
        setupTimer()

    }
    
    internal func imagePressed(sender: UIGestureRecognizer) {
        
        if let delegate = customDelegate {
            if let responsedMethod = delegate.ADScrollerViewDidclicked {
                responsedMethod((sender.view?.tag)!)
            }else{
                print("delegate method NOT implemented yet!")
            }
        }else{
            print("delegate error")
        }
    }

    override func drawRect(rect: CGRect) {

        //attachImageView(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRectMake(10, 10, self.bounds.size.width - 20, 20)
        
        scrollerView.frame = self.bounds
        scrollerView.contentSize = CGSizeMake(self.bounds.size.width * CGFloat(imageArray.count), self.bounds.size.height)
        
        pageRollingWidth = scrollerView.frame.size.width
        
        pagecontrol.center = CGPointMake(scrollerView.frame.size.width / 2, scrollerView.frame.size.height - 10)
        
        var i = 0
        for view in scrollerView.subviews {
            if let imgView = view as? UIImageView {
                imgView.frame = CGRectMake(scrollerView.frame.size.width * CGFloat(i), 0, scrollerView.frame.size.width, scrollerView.frame.size.height)
                i += 1
            }

        }
        
        self.scrollerView.setContentOffset(CGPointMake(pageRollingWidth * CGFloat(currentDisplyedPage), 0), animated: false)

    }

    private func attachImageView(rect: CGRect) {
        for i in 0 ..< imageArray.count {
            
            let imgView = UIImageView()
            imgView.contentMode = .ScaleAspectFill
            imgView.backgroundColor = UIColor.clearColor()
            imgView.clipsToBounds = true
            
            if let urlString = imageArray[i][imageKey] where urlString.characters.count > 0 {
                if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                    imgView.kf_showIndicatorWhenLoading = true
                    imgView.kf_setImageWithURL(NSURL(string: urlString)!, placeholderImage: UIImage(named: "imagePlaceHolder"), optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                        //print("loading...")

                        }, completionHandler: { (image, error, cacheType, imageURL) in
                            //print("completionHandler...")

                    })
                }else{
                    imgView.image = UIImage(named: urlString)
                }
            }else{
                imgView.image = UIImage(named: "imagePlaceHolder")
            }
            
            imgView.frame = CGRectMake(rect.size.width * CGFloat(i), 0, rect.size.width, rect.size.height)
            imgView.tag = i
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ADScrollerView.imagePressed(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            imgView.addGestureRecognizer(tap)
            imgView.userInteractionEnabled = true
            
            if !scrollerView.subviews.contains(imgView) {
                scrollerView.addSubview(imgView)
            }
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentDisplyedPage = PageNumberInScrollview(scrollView)
    }
    
    private func PageNumberInScrollview(scrollView: UIScrollView) -> Int {
        let contentOffset = scrollView.contentOffset
        let viewsize = scrollView.bounds.size
        let horizontalPage = max(0.0, contentOffset.x / viewsize.width)
        return Int(horizontalPage)
    }
    
    internal func moveImage() {
        if currentDisplyedPage < imageArray.count - 1 {
            currentDisplyedPage += 1
        }else{
            currentDisplyedPage = 0
        }
        self.scrollerView.setContentOffset(CGPointMake(pageRollingWidth * CGFloat(currentDisplyedPage), 0), animated: true)
    }
    
    
}
