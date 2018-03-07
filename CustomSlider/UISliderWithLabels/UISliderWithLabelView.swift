
import UIKit

/// enum for label positions
public enum SliderLabelStyle : Int {
    /// lower and upper labels stick to the left and right of slider
    case STICKY
    
    /// lower and upper labels follow position of lower and upper thumbs
    case FOLLOW
}

/// delegate for changed value
public protocol SliderViewDelegate: class {
    /// slider value changed
    func sliderValueChanged(slider: CustomSlider?)
}

/// optional implementation
public extension SliderViewDelegate{
    func sliderValueChanged(slider: CustomSlider?){}
}

/// Range slider with labels for upper and lower thumbs, title label and configurable step value (optional)
open class SliderView: UIView {
    
    //MARK: properties
    
    open var delegate: SliderViewDelegate? = nil
    
    /// Range slider
    open var rangeSlider : CustomSlider? = nil
    
    /// Display title
    open var titleLabel : UILabel? = nil

    /// upper value label for displaying selected upper value
    open var currentLabel : UILabel? = nil
 
    /// display format for upper value. Default to %.0f to display value as Int
    open var CustomUpperDisplayStringFormat: String = "%.0f" {
        didSet {
            updateLabelDisplay()
        }
    }
    
    /// vertical spacing
    open var spacing: CGFloat = 4.0
    
    /// position of thumb labels. Set to STICKY to stick to left and right positions. Set to FOLLOW to follow left and right thumbs
    open var CustomthumbLabelStyle: SliderLabelStyle = .FOLLOW
    
    /// minimum value
    @IBInspectable open var minimumValue: Double = 0.0 {
        didSet {
            self.rangeSlider?.minimumValue = minimumValue
        }
    }
    
    /// max value
    @IBInspectable open var maximumValue: Double = 1000.0 {
        didSet {
            self.rangeSlider?.maximumValue = maximumValue
        }
    }
    
  
    /// value for upper thumb
    @IBInspectable open var upperValue: Double = 0.0 {
        didSet {
            self.rangeSlider?.currentValue = upperValue
            self.updateLabelDisplay()
        }
    }
    
    /// stepValue. If set, will snap to discrete step points along the slider . Default to nil
    //    @IBInspectable open var stepValue: Double? = nil {
    
    open var stepValue: Double? = nil {
        didSet {
            self.rangeSlider?.stepValue = stepValue
        }
    }
    

    
    /// tint color for track 
    @IBInspectable open var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            self.rangeSlider?.trackTintColor = trackTintColor
        }
    }
    
    
    /// track highlight tint color
    @IBInspectable open var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            self.rangeSlider?.trackHighlightTintColor = trackHighlightTintColor
        }
    }
    
    
    /// thumb tint color
    @IBInspectable open var thumbTintColor: UIColor = UIColor.white {
        didSet {
            self.rangeSlider?.thumbTintColor = thumbTintColor
        }
    }
    
    /// thumb border color
    @IBInspectable open var thumbBorderColor: UIColor = UIColor.gray {
        didSet {
            self.rangeSlider?.thumbBorderColor = thumbBorderColor
        }
    }
    
    
    /// thumb border width
    @IBInspectable open var thumbBorderWidth: CGFloat = 0.5 {
        didSet {
            self.rangeSlider?.thumbBorderWidth = thumbBorderWidth
            
        }
    }
    
    /// set 0.0 for square thumbs to 1.0 for circle thumbs
    @IBInspectable open var curvaceousness: CGFloat = 1.0 {
        didSet {
            self.rangeSlider?.curvaceousness = curvaceousness
        }
    }
    
    /// thumb width and height
    @IBInspectable open var thumbSize: CGFloat = 32.0 {
        didSet {
            if let slider = self.rangeSlider {
                var oldFrame = slider.frame
                oldFrame.size.height = thumbSize
                slider.frame = oldFrame
            }
        }
    }
    
    //MARK: init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    /// setup
    open func setup() {
        self.autoresizingMask = [.flexibleWidth]
        
        self.titleLabel = UILabel(frame: .zero)
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.titleLabel?.text = ""
        self.addSubview(self.titleLabel!)
    
        self.currentLabel = UILabel(frame: .zero)
        self.currentLabel?.numberOfLines = 1
        self.currentLabel?.font = UIFont.systemFont(ofSize: 14.0)
        self.currentLabel?.text = ""
        self.currentLabel?.textAlignment = .center
        self.addSubview(self.currentLabel!)
        
        self.rangeSlider = CustomSlider(frame: .zero)
        self.addSubview(self.rangeSlider!)
        
        self.updateLabelDisplay()
        
        self.rangeSlider?.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
    }
    
    //MARK: range slider delegage
    
    /// Range slider change events. Upper labels will be updated accordingly.
    /// Selected value for filterItem will also be updated
    ///
    /// - Parameter rangeSlider: the changed rangeSlider
    @objc open func rangeSliderValueChanged(_ rangeSlider: CustomSlider) {
        
        delegate?.sliderValueChanged(slider: rangeSlider)
        
        self.updateLabelDisplay()
        
    }
    
    //MARK: -
    
    // update labels display
    open func updateLabelDisplay() {
        

        self.currentLabel?.text = String(format: self.CustomUpperDisplayStringFormat, rangeSlider!.currentValue )
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        if self.currentLabel != nil {

            // for stepped value we animate the labels
            if self.stepValue != nil && self.CustomthumbLabelStyle == .FOLLOW
            {
                UIView.animate(withDuration: 0.1, animations: {
                    self.layoutSubviews()
                })
            }
            else {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
       }
    }
    
    /// layout subviews
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if let titleLabel = self.titleLabel ,
            let upperLabel = self.currentLabel , let rangeSlider = self.rangeSlider {
            
            let commonWidth = self.bounds.width
            var titleLabelMaxY : CGFloat = 0
            
            if !titleLabel.isHidden && titleLabel.text != nil && titleLabel.text!.characters.count > 0 {
                titleLabel.frame = CGRect(x: 0,
                                          y: 0,
                                          width: commonWidth  ,
                                          height: (titleLabel.font.lineHeight + self.spacing ) )
                
                titleLabelMaxY = titleLabel.frame.origin.y + titleLabel.frame.size.height
            }
            rangeSlider.frame = CGRect(x: 0,
                                       y: titleLabelMaxY + upperLabel.font.lineHeight +  self.spacing,
                                       width: commonWidth ,
                                       height: thumbSize )
            
          
            let upperWidth = self.estimatelabelSize(font: upperLabel.font, string: upperLabel.text!, constrainedToWidth: Double(commonWidth)).width
            
            var upperLabelX : CGFloat = 0
            
            
            if self.CustomthumbLabelStyle == .FOLLOW {
                upperLabelX = rangeSlider.currentThumbLayer.frame.midX  - upperWidth / 2
            }
            else {
                upperLabelX = rangeSlider.frame.origin.x + rangeSlider.frame.size.width - thumbSize + self.spacing
            }

            
            upperLabel.frame = CGRect(      x: upperLabelX,
                                            y: titleLabelMaxY,
                                            width: upperWidth ,
                                            height: upperLabel.font.lineHeight + self.spacing )
            
        }
        
    }
    
    // return the best size that fit within the box
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        if let titleLabel = self.titleLabel  {
            
            var height : CGFloat = 0
            
            var titleLabelMaxY : CGFloat = 0
            
            if !titleLabel.isHidden && titleLabel.text != nil && titleLabel.text!.characters.count > 0 {
                titleLabelMaxY = titleLabel.font.lineHeight + self.spacing
            }
            
            height = titleLabelMaxY + (currentLabel?.font.lineHeight)! + self.spacing + thumbSize
            
            return CGSize(width: size.width, height: height)
            
        }
        
        return size
        
    }
    
    /// get size for string of this font
    ///
    /// - parameter font: font
    /// - parameter string: a string
    /// - parameter width:  constrained width
    ///
    /// - returns: string size for constrained width
    private func estimatelabelSize(font: UIFont,string: String, constrainedToWidth width: Double) -> CGSize{
        return string.boundingRect(with: CGSize(width: width, height: DBL_MAX),
                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                   attributes: [NSAttributedStringKey.font: font],
                                   context: nil).size
        
    }
    
    
}

