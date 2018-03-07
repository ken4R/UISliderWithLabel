//
//  ViewController.swift
//  CustomSlider
//
//  Created by Ken 4R on 07/03/2018.
//  Copyright © 2018 leadershift. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.white
        
        let mycustomSliderView = SliderView(frame: CGRect(x:20, y:view.center.y - 15, width: view.frame.size.width - 40, height: 30))
        
        mycustomSliderView.trackHighlightTintColor = UIColor.init(red: 102/255, green: 162/255, blue: 220/255, alpha: 1.0)
        mycustomSliderView.maximumValue = 1000
        mycustomSliderView.upperValue = 300.0
        
        mycustomSliderView.CustomthumbLabelStyle = .FOLLOW
        mycustomSliderView.CustomUpperDisplayStringFormat = "%.0f "
        
        mycustomSliderView.sizeToFit()
        self.view.addSubview(mycustomSliderView)
        
     //   self.view.backgroundColor = UIColor.red
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

