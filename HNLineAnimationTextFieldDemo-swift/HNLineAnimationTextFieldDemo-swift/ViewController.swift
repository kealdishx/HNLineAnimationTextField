//
//  ViewController.swift
//  HNLineAnimationTextFieldDemo-swift
//
//  Created by zakariyyaSv on 16/4/26.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginOnClick() {
        HNLineAnimationManager.sharedInstance().startLoadingAnimation()
        let time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(5 * NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) { 
            () -> Void in
            HNLineAnimationManager.sharedInstance().stopLoadingAnimation()
        }
    }

}

