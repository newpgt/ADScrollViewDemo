//
//  ViewController.swift
//  ADScrollViewDemo
//
//  Created by NeoZ on 12/6/16.
//  Copyright © 2016 NeoZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ADScrollerViewDelegate {

    @IBOutlet weak var adScrollerView: ADScrollerView!
    
    override func viewWillAppear(animated: Bool) {
        adScrollerView.setupTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        adScrollerView.invalidateTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imgArray : [[String: String]]  = [
                        ["image":"http://pic22.nipic.com/20120715/3247605_105802332102_2.jpg","title":"Golf"],
                        ["image":"http://pic5.nipic.com/20100127/4234387_162601036066_2.jpg","title":"Night view"],
                        ["image":"http://pic39.nipic.com/20140321/9448607_215633671000_2.jpg","title":"Lake view"],
                        ["image":"http://pic5.nipic.com/20100124/4234387_223729015977_2.jpg","title":"Snow mountain"],
                        ["image":"http://pic5.nipic.com/20100127/4234387_162917046208_2.jpg","title":""]
        ]
        
        adScrollerView.customDelegate = self
        adScrollerView.imageArray = imgArray
        self.automaticallyAdjustsScrollViewInsets = false  //needed!
    }
    
    func ADScrollerViewDidclicked(index: Int) {
        print(index)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

