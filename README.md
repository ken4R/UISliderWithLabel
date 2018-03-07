# UISliderWithLabel


![capture d ecran 2018-03-07 a 11 41 48](https://user-images.githubusercontent.com/17429889/37088628-4f3aa99a-21fe-11e8-9d50-c389d1ceb554.png)



Custom Slider with a followed slider

        //create your custom slider
        let mycustomSliderView = SliderView(frame: CGRect(x:x, y:y, width:width, height: height))
        
        //to change the track highlightTintColor
        mycustomSliderView.trackHighlightTintColor = UIColor.init(red: 102/255, green: 162/255, blue: 220/255, alpha: 1.0)
        
        //to change the maximum Value
        mycustomSliderView.maximumValue = 1000
        
        //to change the current value
        mycustomSliderView.upperValue = 300.0
        
        //to change the thumb Label Style
        mycustomSliderView.CustomthumbLabelStyle = .FOLLOW
        
        //to change the label
        mycustomSliderView.CustomUpperDisplayStringFormat = "%.0f "
        
        mycustomSliderView.sizeToFit()
        
        //add the Slider to your view
        self.view.addSubview(mycustomSliderView)
