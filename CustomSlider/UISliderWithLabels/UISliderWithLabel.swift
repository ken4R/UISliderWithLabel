import UIKit
import QuartzCore





/// Range slider track layer. Responsible for drawing the horizontal track
public class SliderTrackLayer: CALayer {
    
    /// owner slider
    weak var rangeSlider: CustomSlider?
    
    /// draw the track
    ///
    /// - Parameter ctx: current graphics context
    override open func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        
        // Clip
        let cornerRadius = bounds.height * slider.curvaceousness / 2.0
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        ctx.addPath(path.cgPath)
        
        // Fill the track
        ctx.setFillColor(slider.trackTintColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        // Fill the highlighted range
        ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
        let upperValuePosition = CGFloat(slider.positionForValue(slider.currentValue))
        let rect = CGRect(x: 0.0, y: 0.0, width: upperValuePosition, height: bounds.height)
        ctx.fill(rect)
    }
}

/// the thumb for current bounds
public class SliderThumbLayer: CALayer {
    
    /// owner slider
    weak var rangeSlider: CustomSlider?
    
    /// whether this thumb is currently highlighted i.e. touched by user
    public var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// stroke color
    public var strokeColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// line width
    public var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    /// draw the thumb
    ///
    /// - Parameter ctx: current graphics context
    override open func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        
        let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
        let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
        let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
        
        // Fill
        ctx.setFillColor(slider.thumbTintColor.cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()
        
        // Outline
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.addPath(thumbPath.cgPath)
        ctx.strokePath()
        
        if highlighted {
            ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}





open class CustomSlider: UIControl {
    
    //MARK: properties
    
    /// minimum value
    @IBInspectable open var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maximumValue, "minimumValue should be lower than maximumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    /// max value
    @IBInspectable open var maximumValue: Double = 100.0 {
        willSet(newValue) {
            assert(newValue > minimumValue, "maximumValue should be greater than minimumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
  
    /// value for upper thumb
    @IBInspectable open var currentValue: Double = 100.0 {
        didSet {
            if currentValue > maximumValue {
                currentValue = maximumValue
            }
            updateLayerFrames()
        }
    }
    
    
    /// stepValue. If set, will snap to discrete step points along the slider . Default to nil
    //  @IBInspectable open var stepValue: Double? = nil {
    open var stepValue: Double? = nil {
        
        willSet(newValue) {
            if newValue != nil {
                assert(newValue! > 0, "stepValue must be positive")
            }
        }
        didSet {
            if let val = stepValue {
                if val <= 0 {
                    stepValue = nil
                }
            }
            
            updateLayerFrames()
        }
    }
  
    /// tint color
    @IBInspectable open var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    /// track highlight tint color
    @IBInspectable open var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    
    /// thumb tint color
    @IBInspectable open var thumbTintColor: UIColor = UIColor.white {
        didSet {
            currentThumbLayer.setNeedsDisplay()
        }
    }
    
    /// thumb border color
    @IBInspectable open var thumbBorderColor: UIColor = UIColor.gray {
        didSet {
            currentThumbLayer.strokeColor = thumbBorderColor
        }
    }
    
    
    /// thumb border width
    @IBInspectable open var thumbBorderWidth: CGFloat = 0.5 {
        didSet {
            currentThumbLayer.lineWidth = thumbBorderWidth
        }
    }
    
    /// set 0.0 for square thumbs to 1.0 for circle thumbs
    @IBInspectable open var curvaceousness: CGFloat = 1.0 {
        didSet {
            if curvaceousness < 0.0 {
                curvaceousness = 0.0
            }
            
            if curvaceousness > 1.0 {
                curvaceousness = 1.0
            }
            
            trackLayer.setNeedsDisplay()
            currentThumbLayer.setNeedsDisplay()
        }
    }
    
    
    /// previous touch location
    fileprivate var previouslocation = CGPoint()
    
    /// track layer
    fileprivate let trackLayer = SliderTrackLayer()
    

    
    /// upper thumb layer
    public let currentThumbLayer = SliderThumbLayer()
    
    /// thumb width
    fileprivate var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    /// frame
    override open var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    //MARK: init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeLayers()
    }
    
    //MARK: layers
    
    /// layout sub layers
    ///
    /// - Parameter of: layer
    override open func layoutSublayers(of: CALayer) {
        super.layoutSublayers(of:layer)
        updateLayerFrames()
    }
    
    /// init layers
    fileprivate func initializeLayers() {
        layer.backgroundColor = UIColor.clear.cgColor
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        

        
        currentThumbLayer.rangeSlider = self
        currentThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(currentThumbLayer)
    }
    
    /// update layer frames
    open func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/3)
        trackLayer.setNeedsDisplay()

        
        let upperThumbCenter = CGFloat(positionForValue(currentValue))
        currentThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth/2.0, y: 0.0, width: thumbWidth, height: thumbWidth)
        currentThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    /// thumb x position for new value
    open func positionForValue(_ value: Double) -> Double {
        if (maximumValue == minimumValue) {
            return 0
        }
        
        return Double(bounds.width - thumbWidth) * (value - minimumValue) / (maximumValue - minimumValue)
            + Double(thumbWidth/2.0)
    }
    
    
    /// bound new value within lower and upper value
    ///
    /// - Parameters:
    ///   - value: value to set
    ///   - lowerValue: lower value
    ///   - upperValue: upper value
    /// - Returns: current value
    open func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    
    // MARK: - Touches
    
    /// begin tracking
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)
        
        // set highlighted positions for lower and upper thumbs

        
        if currentThumbLayer.frame.contains(previouslocation) {
            currentThumbLayer.highlighted = true
        }
        
        return currentThumbLayer.highlighted
    }
    
    /// update positions for lower and upper thumbs
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        var deltaValue : Double = 0
        
        if (bounds.width != bounds.height) {
            deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        }
        
        
        previouslocation = location
        if currentThumbLayer.highlighted {
            currentValue = boundValue(currentValue + deltaValue, toLowerValue: minimumValue, upperValue: maximumValue)
        }
        
        
        // only send changed value if stepValue is not set. We will trigger this later in endTracking
        if stepValue == nil {
            sendActions(for: .valueChanged)
        }
        
        return true
    }
    
    /// end touch tracking. Unhighlight the two thumbs
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        currentThumbLayer.highlighted = false
        
        // let slider snap after user stop dragging
        if let stepValue = stepValue {
            currentValue = round(currentValue / stepValue) * stepValue
            sendActions(for: .valueChanged)
        }
        
        
    }
    
}
